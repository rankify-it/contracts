// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {LibTBG} from "../libraries/LibTurnBasedGame.sol";
import {IRankifyInstanceCommons} from "../interfaces/IRankifyInstanceCommons.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IRankToken} from "../interfaces/IRankToken.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {LibQuadraticVoting} from "./LibQuadraticVoting.sol";
import "hardhat/console.sol";

library LibRankify {
    using LibTBG for LibTBG.GameInstance;
    using LibTBG for uint256;
    using LibTBG for LibTBG.GameSettings;
    using LibQuadraticVoting for LibQuadraticVoting.qVotingStruct;

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function getGameStorage(uint256 gameId) internal view returns (IRankifyInstanceCommons.RInstance storage game) {
        bytes32 position = LibTBG.getGameDataStorage(gameId);
        assembly {
            game.slot := position
        }
    }

    function RInstanceStorage() internal pure returns (IRankifyInstanceCommons.RInstanceSettings storage bog) {
        bytes32 position = LibTBG.getDataStorage();
        assembly {
            bog.slot := position
        }
    }

    bytes32 internal constant _PROPOSAL_PROOF_TYPEHASH =
        keccak256("signProposalByGM(uint256 gameId,uint256 turn,bytes32 proposalNHash,string encryptedProposal)");
    bytes32 internal constant _VOTE_PROOF_TYPEHASH =
        keccak256("signVote(uint256 vote1,uint256 vote2,uint256 vote3,uint256 gameId,uint256 turn,bytes32 salt)");
    bytes32 internal constant _VOTE_SUBMIT_PROOF_TYPEHASH =
        keccak256("publicSignVote(uint256 gameId,uint256 turn,bytes32 vote1,bytes32 vote2,bytes32 vote3)");

    function enforceIsInitialized() internal view {
        IRankifyInstanceCommons.RInstanceSettings storage settings = RInstanceStorage();
        require(settings.contractInitialized, "onlyInitialized");
    }

    function enforceGameExists(uint256 gameId) internal view {
        enforceIsInitialized();
        require(gameId.gameExists(), "no game found");
    }

    function newGame(uint256 gameId, address gameMaster, uint256 gameRank, address creator) internal {
        LibRankify.enforceIsInitialized();
        IRankifyInstanceCommons.RInstanceSettings storage settings = RInstanceStorage();
        gameId.createGame(gameMaster); // This will enforce game does not exist yet
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        require(gameRank != 0, "game rank not specified");
        if (settings.gamePrice != 0) {
            IERC20(settings.gamePaymentToken).transferFrom(creator, address(this), settings.gamePrice);
            game.paymentsBalance = settings.gamePrice;
        }

        game.createdBy = creator;
        settings.numGames += 1;
        game.rank = gameRank;

        IRankToken rankTokenContract = IRankToken(settings.rankTokenAddress);
        rankTokenContract.mint(address(this), 1, gameRank + 1, "");
        rankTokenContract.mint(address(this), 3, gameRank, "");
    }

    function enforceIsGameCreator(uint256 gameId, address candidate) internal view {
        enforceGameExists(gameId);
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        require(game.createdBy == candidate, "Only game creator");
    }

    function enforceIsGM(uint256 gameId, address candidate) internal view {
        enforceGameExists(gameId);
        require(gameId.getGM() == candidate, "Only game master");
    }

    function _fulfillRankRq(address player, uint256 gameRank, address rankTokenAddress) private {
        IRankToken rankToken = IRankToken(rankTokenAddress);
        rankToken.lock(player, gameRank, 1);
    }

    function joinGame(uint256 gameId, address player) internal {
        enforceGameExists(gameId);
        fulfillRankRq(gameId, player);
        IRankifyInstanceCommons.RInstanceSettings storage _RInstance = RInstanceStorage();
        if (_RInstance.joinGamePrice != 0) {
            IERC20(_RInstance.gamePaymentToken).transferFrom(player, address(this), _RInstance.joinGamePrice);
            IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
            game.paymentsBalance += _RInstance.joinGamePrice;
        }
        gameId.addPlayer(player);
    }

    function closeGame(
        uint256 gameId,
        address beneficiary,
        function(uint256, address) playersGameEndedCallback
    ) internal returns (uint256[] memory) {
        enforceGameExists(gameId);
        emitRankRewards(gameId, gameId.getLeaderBoard());
        (, uint256[] memory finalScores) = gameId.getScores();
        address[] memory players = gameId.getPlayers();
        for (uint256 i = 0; i < players.length; i++) {
            removeAndUnlockPlayer(gameId, players[i]);
            playersGameEndedCallback(gameId, players[i]);
        }
        IRankifyInstanceCommons.RInstanceSettings storage _RInstance = LibRankify.RInstanceStorage();
        IERC20(_RInstance.gamePaymentToken).transfer(beneficiary, (_RInstance.joinGamePrice * players.length) + _RInstance.gamePrice);
        return finalScores;
    }

    function quitGame(
        uint256 gameId,
        address player,
        bool slash,
        function(uint256, address) onPlayerLeftCallback
    ) internal {
        IRankifyInstanceCommons.RInstanceSettings storage _RInstance = RInstanceStorage();
        if (_RInstance.joinGamePrice != 0) {
            uint256 divideBy = slash ? 2 : 1;
            uint256 paymentRefund = _RInstance.joinGamePrice / divideBy;
            IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
            game.paymentsBalance -= paymentRefund;
            IERC20(_RInstance.gamePaymentToken).transfer(player, paymentRefund);
        }
        removeAndUnlockPlayer(gameId, player); // this will throw if game has started or doesnt exist
        onPlayerLeftCallback(gameId, player);
    }

    function cancelGame(uint256 gameId, function(uint256, address) onPlayerLeftCallback, address beneficiary) internal {
        address[] memory players = gameId.getPlayers();
        for (uint256 i = 0; i < players.length; i++) {
            quitGame(gameId, players[i], false, onPlayerLeftCallback); //this will throw if game has started or doesnt exist
        }
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        IRankifyInstanceCommons.RInstanceSettings storage _RInstance = RInstanceStorage();
        uint256 paymentRefund = _RInstance.gamePrice / 2;
        IERC20(_RInstance.gamePaymentToken).transfer(game.createdBy, paymentRefund);
        game.paymentsBalance -= paymentRefund;
        IERC20(_RInstance.gamePaymentToken).transfer(beneficiary, game.paymentsBalance);
        game.paymentsBalance = 0;
        gameId.deleteGame();
    }

    function fulfillRankRq(uint256 gameId, address player) internal {
        IRankifyInstanceCommons.RInstanceSettings storage settings = RInstanceStorage();
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        if (game.rank > 1) {
            _fulfillRankRq(player, game.rank, settings.rankTokenAddress);
            for (uint256 i = 0; i < game.additionalRanks.length; i++) {
                _fulfillRankRq(player, game.rank, game.additionalRanks[i]);
            }
        }
    }

    function emitRankReward(uint256 gameId, address[] memory leaderboard, address rankTokenAddress) private {
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        IRankToken rankTokenContract = IRankToken(rankTokenAddress);
        rankTokenContract.safeTransferFrom(address(this), leaderboard[0], game.rank + 1, 1, "");
        rankTokenContract.safeTransferFrom(address(this), leaderboard[1], game.rank, 2, "");
        rankTokenContract.safeTransferFrom(address(this), leaderboard[2], game.rank, 1, "");
    }

    function emitRankRewards(uint256 gameId, address[] memory leaderboard) internal {
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        IRankifyInstanceCommons.RInstanceSettings storage settings = LibRankify.RInstanceStorage();
        emitRankReward(gameId, leaderboard, settings.rankTokenAddress);
        for (uint256 i = 0; i < game.additionalRanks.length; i++) {
            emitRankReward(gameId, leaderboard, game.additionalRanks[i]);
        }
    }

    function _releaseRankToken(address player, uint256 gameRank, address rankTokenAddress) private {
        IRankToken rankToken = IRankToken(rankTokenAddress);
        rankToken.unlock(player, gameRank, 1);
    }

    function removeAndUnlockPlayer(uint256 gameId, address player) internal {
        enforceGameExists(gameId);
        gameId.removePlayer(player); //This will throw if game is in the process
        IRankifyInstanceCommons.RInstanceSettings storage settings = RInstanceStorage();
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        if (game.rank > 1) {
            _releaseRankToken(player, game.rank, settings.rankTokenAddress);
            for (uint256 i = 0; i < game.additionalRanks.length; i++) {
                _releaseRankToken(player, game.rank, game.additionalRanks[i]);
            }
        }
    }

    function tryPlayerMove(uint256 gameId, address player) internal returns (bool) {
        uint256 turn = gameId.getTurn();
        IRankifyInstanceCommons.RInstanceSettings storage settings = RInstanceStorage();
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        bool expectVote = true;
        bool expectProposal = true;
        if (turn == 1)
            expectVote = false; //Dont expect votes at firt turn
        else if (gameId.isLastTurn()) expectProposal = false; //Dont expect proposals at last turn
        if (game.numPrevProposals < settings.voting.minQuadraticPositons) expectVote = false; // If there is not enough proposals then round is skipped votes cannot be filled
        bool madeMove = true;
        if (expectVote && !game.playerVoted[player]) madeMove = false;
        if (expectProposal && game.proposalCommitmentHashes[player] == "") madeMove = false;
        // console.log("made move", madeMove, expectProposal);
        // console.log(game.proposalCommitmentHashes[player] == "", game.playerVoted[player]);
        if (madeMove) gameId.playerMove(player);
        return madeMove;
    }

    //prevProposersRevealed MUST be submitted sorted according to proposals in ongoingProposals map
    function calculateScoresQuadratic(
        uint256 gameId,
        uint256[][] memory votesRevealed,
        uint256[] memory proposerIndicies
    ) internal returns (uint256[] memory, uint256[] memory) {
        address[] memory players = gameId.getPlayers();
        uint256[] memory scores = new uint256[](players.length);
        uint256[] memory roundScores = new uint256[](players.length);
        bool[] memory playerVoted = new bool[](players.length);
        IRankifyInstanceCommons.RInstanceSettings storage settings = RInstanceStorage();
        IRankifyInstanceCommons.RInstance storage game = getGameStorage(gameId);
        // Convert mappiing to array to pass it to libQuadratic
        for (uint256 i = 0; i < players.length; i++) {
            playerVoted[i] = game.playerVoted[players[i]];
        }
        roundScores = settings.voting.computeScoresByVPIndex(
            votesRevealed,
            playerVoted,
            settings.voting.maxQuadraticPoints,
            proposerIndicies.length

        );
        for (uint256 playerIdx = 0; playerIdx < players.length; playerIdx++) {
            //for each player
            if (proposerIndicies[playerIdx] < players.length) {
                //if player propposed exists
                scores[playerIdx] = gameId.getScore(players[playerIdx]) + roundScores[playerIdx];
                gameId.setScore(players[playerIdx], scores[playerIdx]);
            } else {
                //Player did not propose
            }
        }
        return (scores, roundScores);
    }
}