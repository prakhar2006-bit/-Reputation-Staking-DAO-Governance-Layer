// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Reputation Staking DAO Governance Layer
 * @dev A governance layer where users stake tokens to gain reputation
 *      and vote on DAO proposals.
 */
contract Project {
    struct Proposal {
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    mapping(address => uint256) public reputation;
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    event Staked(address indexed user, uint256 amount);
    event ProposalCreated(uint256 indexed id, string description);
    event Voted(uint256 indexed id, address indexed voter, bool support, uint256 weight);
    event Executed(uint256 indexed id, bool success);

    /**
     * @dev Stake tokens to gain reputation (simulated here without ERC20).
     * In real use-case, integrate ERC20 token transfer.
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Stake must be greater than 0");
        reputation[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Create a new proposal.
     */
    function createProposal(string memory description) external returns (uint256) {
        require(reputation[msg.sender] > 0, "Need reputation to create proposals");
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, description, 0, 0, false);
        emit ProposalCreated(proposalCount, description);
        return proposalCount;
    }

    /**
     * @dev Vote on a proposal using reputation weight.
     */
    function vote(uint256 proposalId, bool support) external {
        require(reputation[msg.sender] > 0, "No reputation to vote");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");

        if (support) {
            proposal.votesFor += reputation[msg.sender];
        } else {
            proposal.votesAgainst += reputation[msg.sender];
        }

        emit Voted(proposalId, msg.sender, support, reputation[msg.sender]);
    }

    /**
     * @dev Execute proposal if majority supports.
     */
    function execute(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");

        bool success = proposal.votesFor > proposal.votesAgainst;
        proposal.executed = true;

        emit Executed(proposalId, success);
    }
}
