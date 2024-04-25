# @version 0.3.10
# @title UpZap
# @author banteg
# @notice deposit YFI into supYFI in less steps
from vyper.interfaces import ERC20

interface Vault:
    def deposit(assets: uint256, receiver: address) -> uint256: nonpayable

yfi: public(immutable(ERC20))
upyfi: public(immutable(ERC20))
supyfi: public(immutable(ERC20))

@external
def __init__():
    yfi = ERC20(0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e)
    upyfi = ERC20(0x95710BDE45C8D384A976Cc58Cc7a7e489576b098)
    supyfi = ERC20(0xCb7DCe63aBE175cA354Dcca9cc10554D255777Ee)
    
    assert yfi.approve(upyfi.address, max_value(uint256))
    assert upyfi.approve(supyfi.address, max_value(uint256))

@external
def deposit(amount: uint256) -> uint256:
    """
    @dev requires yfi allowance
    """
    assert yfi.transferFrom(msg.sender, self, amount)
    minted: uint256 = Vault(upyfi.address).deposit(amount, self)
    return Vault(supyfi.address).deposit(minted, msg.sender)
