pragma solidity =0.5.16;


/**
 *    _____               _____                          __   __     _               ___                            __     __
 *   / ___/ ____ _ __  __/ ___/ ____   ____ ___   ___   / /_ / /_   (_)____   ____ _|__ \   _      __ ____   _____ / /____/ /
 *   \__ \ / __ `// / / /\__ \ / __ \ / __ `__ \ / _ \ / __// __ \ / // __ \ / __ `/__/ /  | | /| / // __ \ / ___// // __  /
 *  ___/ // /_/ // /_/ /___/ // /_/ // / / / / //  __// /_ / / / // // / / // /_/ // __/ _ | |/ |/ // /_/ // /   / // /_/ /
 * /____/ \__,_/ \__, //____/ \____//_/ /_/ /_/ \___/ \__//_/ /_//_//_/ /_/ \__, //____/(_)|__/|__/ \____//_/   /_/ \__,_/
 *              /____/                                                     /____/
 *
 * https://SaySomething2.world
 * https://0123eth.com
 *
 * TEAM "push.game" PRESENTS
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0)
        {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}


/**
 * @dev Wrappers for address.
 */
library AddressLib {
    function isNotContract(address account) internal view returns (bool)
    {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size == 0;
    }

    function toPayable(address account) internal pure returns (address payable)
    {
        return address(uint160(account));
    }
}


/**
 * @dev Interface of cookie contract
 */
interface ICookie {
    function mint(address account) external returns (uint256);
}


/**
 * @dev Interface of subsidy contract
 */
interface ISubsidy {
    function transferSubsidy(address payable recipient) external;
}


/**
 * @dev Interface of game.
 */
library GameLib {
    struct Message {
        address payable account;
        bytes text;
        uint256 blockNumber;
    }

    struct Cookie {
        address payable player;
        address payable adviser;
        uint256 playerWeis;
        uint256 adviserWeis;
        uint256 messageId;
    }

    struct Round {
        uint256 openedBlock;
        uint256 closingBlock;
        uint256 closedTimestamp;
        uint256 openingWinnerFund;
        uint256 closingWinnerFund;
        address payable opener;
        uint256 openerBonusWeis;
    }

    struct WinnerRecord {
        uint256 messageSerial;
        uint256 weis;
    }

    struct Shareholder {
        uint256 stakingWeis;
        uint256 profitWeis;
        uint256 firstBlockNumber;
    }

    struct ShareholderBidLog {
        address payable account;
        uint256 stakingBefore;
        uint256 stakingAfter;
        uint256 blockNumber;
    }
}


/**
 * @dev Structs of player.
 */
library PlayerLib {
    using SafeMath for uint256;

    struct Player {
        uint256 serial;
        bytes name;
        address payable adviser;
        address payable[] followers;
        uint256[] messageIds;
        uint256[] cookieIds;
        uint256[] followerCookieIds;
        uint256 pinnedMessageSerial;
        uint256 followersMessageCounter;
        uint256 surpriseWeis;
        uint256 bonusWeis;
    }

    function isPlayer(Player memory player)
        internal
        pure
        returns (bool)
    {
        return player.adviser != address(0);
    }

    function surpriseQuota(Player memory player)
        internal
        pure
        returns (uint256 quota, uint256 cap)
    {
        // not player, or not valid
        if (player.adviser == address(0) || player.messageIds.length == 0)
        {
            return (0, 0);
        }

        // no cap
        if (player.followersMessageCounter >= 10)
        {
            cap = 0;
        }

        // x1000
        else if (player.followersMessageCounter >= 5)
        {
            cap = 123 ether;
        }

        // x100
        else if (player.followersMessageCounter >= 2)
        {
            cap = 12.3 ether;
        }

        // x10, default
        else
        {
            cap = 1.23 ether;
        }

        // quota
        if (cap > 0 && cap >= player.surpriseWeis)
        {
            quota = cap.sub(player.surpriseWeis);
        }
    }
}


/**
 * @dev Game Contract
 */
contract Game {
    using SafeMath for uint256;
    using AddressLib for address;
    using PlayerLib for PlayerLib.Player;

    string public name = 'SaySomething2.world';
    string public symbol = 'PUSH';
    uint8 public decimals = 3;

    ICookie private _cookieContract;
    ISubsidy private _subsidyContract;
    address payable private _devFund;

    uint256 private _timer;
    uint256 private _playerSerial;
    uint256 private _cookieFund;
    uint256 private _surpriseIssued;
    uint256 private _bonusIssued;
    uint256 private _cookieIssued;
    uint256 private _shareholderIssued;
    uint256 private _halfShareholdersStaking;

    uint8 constant WINNERS_PER_ROUND = 10;
    uint8 constant SHAREHOLDER_MAX_POSITION = 6;
    uint8 constant TOP_PLAYER_MAX_POSITION = 20;
    uint256 constant BALANCE_DEFAULT = 123;
    uint256 constant PUSH_COMMAND = 0.123 ether;
    uint256 constant AUTO_ADVISER_COMMAND = 0.2 ether;
    uint256 constant RENAME_COMMAND = 0.01 ether;
    uint256 constant PLAYER_SURPRISE = 0.0005 ether;
    uint256 constant PLAYER_SUBSIDY = 0.0984 ether;
    uint256 constant DEV_FUND_DEPOSIT = 0.003 ether;
    uint256 constant TIMER_INIT = 10 hours;
    uint256 constant TIMER_STEP = 5 minutes;
    uint256 constant TIMER_CAP = 100 minutes;
    uint256 constant SHAREHOLDER_STEP = 0.1 ether;

    uint8[11] private _BONUS_COUNTERS = [
        0,
        2, 2, 2, 2, 2,
        5, 5, 5, 5, 5
    ];

    uint256[11] private _BONUS_REWARDS = [
        0.0123 ether,
        0.00123 ether, 0.00123 ether, 0.00123 ether, 0.00123 ether, 0.00123 ether,
        0.00123 ether, 0.00123 ether, 0.00123 ether, 0.00123 ether, 0.00123 ether
    ];

    uint256[WINNERS_PER_ROUND] private _WINNER_PERCENT = [
        50,
        10,
        5, 5, 5, 5,
        4, 3, 2, 1
    ];

    GameLib.Message[] private _message;
    GameLib.Round[] private _round;
    GameLib.Cookie[] private _cookie;
    GameLib.ShareholderBidLog[] private _shareholderBid;
    mapping (uint8 => address payable) private _topPlayers;
    mapping (uint8 => address payable) private _shareholders;
    mapping (uint256 => uint256) public block2timestamp;
    mapping (uint256 => address payable) public serial2player;
    mapping (address => PlayerLib.Player) private _player;
    mapping (address => GameLib.Shareholder) private _shareholder;
    mapping (uint256 => GameLib.WinnerRecord[WINNERS_PER_ROUND]) private _roundWinners;


    event Transfer(address indexed from, address indexed to, uint256 value);

    // ...
}
