import ape


def test_zap_no_approve(bunny, yfi, zap):
    with ape.reverts("revert: ERC20: transfer amount exceeds allowance"):
        zap.deposit("1 ether", sender=bunny)


def test_zap_success(bunny, yfi, zap, supyfi):
    yfi.approve(zap, "1 ether", sender=bunny)
    tx = zap.deposit("1 ether", sender=bunny)
    shares = tx.events[-1]["value"]
    assert supyfi.Deposit(owner=str(bunny)) in tx.events
    assert supyfi.balanceOf(bunny) == shares
