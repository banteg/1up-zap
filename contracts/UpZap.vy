# @version 0.3.10
# @title UpZap
# @author banteg
# @notice deposit YFI into supYFI with Permit2
from vyper.interfaces import ERC20
from vyper.interfaces import ERC4626

struct TokenPermissions:
    token: address
    amount: uint256

struct PermitTransferFrom:
    permitted: TokenPermissions
    nonce: uint256
    deadline: uint256

struct SignatureTransferDetails:
    to: address
    requestedAmount: uint256

interface Permit2:
    def permitTransferFrom(
        permit: PermitTransferFrom,
        transferDetails: SignatureTransferDetails,
        owner: address,
        signature: Bytes[65]
    ): nonpayable

yfi: public(immutable(ERC20))
upyfi: public(immutable(address))
supyfi: public(immutable(address))
permit2: immutable(Permit2)

@external
def __init__():
    yfi = ERC20(0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e)
    upyfi = 0x95710BDE45C8D384A976Cc58Cc7a7e489576b098
    supyfi = 0xCb7DCe63aBE175cA354Dcca9cc10554D255777Ee
    permit2 = Permit2(0x000000000022D473030F116dDEE9F6B43aC78BA3)
    
    assert yfi.approve(upyfi, max_value(uint256))
    assert ERC20(upyfi).approve(supyfi, max_value(uint256))

@external
def deposit(amount: uint256) -> uint256:
    """
    @dev requires yfi allowance
    """
    assert yfi.transferFrom(msg.sender, self, amount)
    minted: uint256 = ERC4626(upyfi).deposit(amount, self)
    return ERC4626(supyfi).deposit(minted, msg.sender)

@external
def deposit_permit(amount: uint256, nonce: uint256, deadline: uint256, signature: Bytes[65]) -> uint256:
    """
    @dev requires yfi allowance to permit2
    """
    permit2.permitTransferFrom(
        PermitTransferFrom({
            permitted: TokenPermissions({token: yfi.address, amount: amount}),
            nonce: nonce,
            deadline: deadline
        }),
        SignatureTransferDetails({to: self, requestedAmount: amount}),
        msg.sender,
        signature,
    )
    minted: uint256 = ERC4626(upyfi).deposit(amount, self)
    return ERC4626(supyfi).deposit(minted, msg.sender)
