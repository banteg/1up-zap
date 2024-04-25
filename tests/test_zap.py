import ape
from eip712 import EIP712Message, EIP712Type


class TokenPermissions(EIP712Type):
    token: "address"
    amount: "uint256"


class PermitTransferFrom(EIP712Message):
    _name_ = "Permit2"
    _chainId_ = 1
    _verifyingContract_ = "0x000000000022D473030F116dDEE9F6B43aC78BA3"

    permitted: TokenPermissions
    spender: "address"
    nonce: "uint256"
    deadline: "uint256"


def test_zap_no_approve(ychad, zap):
    with ape.reverts("revert: ERC20: transfer amount exceeds allowance"):
        zap.deposit("1 ether", sender=ychad)


def test_zap_success(ychad, yfi, zap, supyfi):
    yfi.approve(zap, "1 ether", sender=ychad)
    tx = zap.deposit("1 ether", sender=ychad)
    shares = tx.events[-1]["value"]
    assert supyfi.Deposit(owner=str(ychad)) in tx.events
    assert supyfi.balanceOf(ychad) == shares


def test_permit_domain(permit2, zap, yfi):
    permit = PermitTransferFrom(TokenPermissions(str(yfi), 10**18), str(zap), 0, 2**128)
    assert permit2.DOMAIN_SEPARATOR() == permit.signable_message.header


def test_permit_deposit(permit2, yfi, ychad, user, zap, chain, supyfi):
    amount = 10**18
    yfi.transfer(user, amount, sender=ychad)
    yfi.approve(permit2, 2**256 - 1, sender=user)

    # produce a permit
    nonce = chain.blocks[-1].timestamp
    deadline = nonce + 86400
    permit = PermitTransferFrom(
        TokenPermissions(str(yfi), amount), str(zap), nonce, deadline
    )
    signature = user.sign_message(permit).encode_rsv()

    tx = zap.deposit_permit(amount, nonce, deadline, signature, sender=user)
    # tx.show_trace()
    assert supyfi.balanceOf(user) == tx.events[-1]["value"]
