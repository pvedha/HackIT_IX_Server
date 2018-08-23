import solc
from flask import Flask, request, jsonify
from flask_restful import Resource, Api
from sqlalchemy import create_engine
from json import dumps
from flask_httpauth import HTTPBasicAuth
from solc import compile_source
from sqlite import SQLDB

# db_connect = create_engine('sqlite:///chinook.db')
app = Flask(__name__)
api = Api(app)

hostIP='10.78.213.217'
auth = HTTPBasicAuth()
sourcePath = '/source/'

db = SQLDB()


@app.route('/user/authenticate/<userName>', methods=['GET'])
# @auth.login_required
def authenticate(userName):
  return jsonify(db.getAddress(userName))

@app.route('/user/add', methods=['POST'])
# @auth.login_required
def addUser():
  content = request.json
  return jsonify(db.addUser(content["userName"], content["userId"], content["password"], content["passphrase"], content["address"]))

@app.route(sourcePath + 'compile', methods=['POST'])
def getCodeAndABI():
  content = request.json
  compiled_sol = compile_source(content["sourceCode"]) # Compiled source code
  return jsonify(compiled_sol)


@app.route(sourcePath + 'sample', methods=['GET'])
def getSampleCode():
  sampleSource = ""
  with open('Sample.sol', 'r') as myfile:
      sampleSource = myfile.read()
    # str = open('very_Important.txt', 'r').read()
  return jsonify({"sampleSource" : sampleSource})

@app.route('/contract/add', methods=['POST'])
def addContract():
  content = request.json
  result = db.addContract(content["owner"], content["ownerAddress"], content["contractName"], content["contractAddress"], content["byteCode"], content["abi"]);
  items = []
  for item in content["beneficiaries"]:
    items.append([item, content["contractName"], content["contractAddress"], "Beneficiary"])
  items.append([content["ownerAddress"], content["contractName"], content["contractAddress"], "Owner"])
  result |= db.updateContractDetails(items)
  return jsonify(result)

@app.route('/contract/updateDetails', methods=['POST'])
def updateContractDetails():
  content = request.json
  items = []
  for item in content:
    items.append([item["userId"], item["contractName"], item["contractAddress"], item["role"]])
  result = db.updateContractDetails(items);
  return jsonify(result)

@app.route('/contract/view/all', methods=['GET'])
def viewAllContract():
  result = db.viewAllContracts();
  return jsonify(result)

@app.route('/contract/view/address/<address>', methods=['GET'])
def viewMyContracts(address):
  # content = request.json
  result = db.viewMyContracts(address);
  return jsonify(result)

@app.route('/contract/load/<address>', methods=['GET'])
def loadContract(address):
  result = db.loadContract(address);
  return jsonify(result)

@app.route('/system/clear', methods=['POST'])
def clearDB():
  result = db.clearDB();
  return jsonify(result)

if __name__ == '__main__':
  app.run(host=hostIP, port=80, debug=True)