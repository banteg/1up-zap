from ape import Contract
import pytest


@pytest.fixture
def bunny(accounts):
    return accounts["0x7A1057E6e9093DA9C1D4C1D049609B6889fC4c67"]


@pytest.fixture
def yfi():
    return Contract("0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e")


@pytest.fixture
def upyfi():
    return Contract("0x95710BDE45C8D384A976Cc58Cc7a7e489576b098")


@pytest.fixture
def supyfi():
    return Contract("0xCb7DCe63aBE175cA354Dcca9cc10554D255777Ee")


@pytest.fixture
def permit2():
    return Contract("0x000000000022D473030F116dDEE9F6B43aC78BA3")


@pytest.fixture
def zap(project, accounts):
    return project.UpZap.deploy(sender=accounts[0])
