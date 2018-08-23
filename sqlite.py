from sqlalchemy import create_engine, connectors
import sqlite3

class SQLDB():

    def __init__(self):
        self.conn = sqlite3.connect('SmartContract.db')
        # self.initDB()

    def addUser(self, userName, userId, password, passphrase, address):
        query = "INSERT INTO users values ('%s','%s','%s','%s','%s')"%(userName, address, password, passphrase, userId)
        con = sqlite3.connect('SmartContract.db')
        c = con.cursor()
        try:
            c.execute(query)
            con.commit()
            return True
        except:
            return False

    def getAddress(self, userName):
        c = sqlite3.connect('SmartContract.db').cursor()
        t = (userName,)
        c.execute('SELECT * FROM users WHERE userName=?', t)
        return [row for row in c.execute('SELECT * FROM users WHERE userName=?', t)]
    
    def updateContractDetails(self, items):
        con = sqlite3.connect('SmartContract.db')
        c = con.cursor()
        try:
            c.executemany('INSERT INTO MyContracts values(?,?,?,?)' , items)
            con.commit()
            return True
        except:
            return  False
        
    def viewAllContracts(self):
        c = sqlite3.connect('SmartContract.db').cursor()
        return [row for row in c.execute('SELECT * FROM Contracts')]

    def viewMyContracts(self, address):
        c = sqlite3.connect('SmartContract.db').cursor()
        query = "select c.contractName, c.contractAddress, c.owner, c.ownerAddress, c.abi, mc.role from Contracts c, MyContracts mc where mc.userId = '%s' and mc.contractAddress == c.contractAddress"%address
        return [row for row in c.execute(query)]

    def loadContract(self, address):
        c = sqlite3.connect('SmartContract.db').cursor()
        query = "select ownerAddress, abi from Contracts where contractAddress = '%s'"%address
        return [row for row in c.execute(query)]

    def addContract(self, owner, ownerAdd, contractName, contractAdd, byteCode, abi):
        con = sqlite3.connect('SmartContract.db')
        c = con.cursor()
        try:
            c.execute('INSERT INTO Contracts values("%s","%s","%s","%s","%s","%s")' % ( owner, ownerAdd, contractName, contractAdd, byteCode, abi))
            con.commit()
            return True
        except:
            return  False

    def clearDB(self):
        return self.executeQuery(["DELETE FROM MyContracts", "DELETE FROM Contracts"])


    def executeQuery(self, queries):
        con = sqlite3.connect('SmartContract.db')
        c = con.cursor()
        try:
            for q in queries:
                c.execute(q);
            con.commit()
            return True
        except:
            return False

    def initDB(self):
        c = self.conn.cursor()

        # Create table
        c.execute('''CREATE TABLE stocks
                     (date text, trans text, symbol text, qty real, price real)''')

        # Insert a row of data
        c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")

        # Larger example that inserts many records at a time
        purchases = [('2006-03-28', 'BUY', 'IBM', 1000, 45.00),
                     ('2006-04-05', 'BUY', 'MSFT', 1000, 72.00),
                     ('2006-04-06', 'SELL', 'IBM', 500, 53.00),
                     ]
        c.executemany('INSERT INTO stocks VALUES (?,?,?,?,?)', purchases)
        # Save (commit) the changes
        self.conn.commit()

        # We can also close the connection if we are done with it.
        # Just be sure any changes have been committed or they will be lost.
        self.conn.close()

    def getSampleData(self):
        c = sqlite3.connect('example.db').cursor()
        t = ('RHAT',)
        c.execute('SELECT * FROM stocks WHERE symbol=?', t)
        return [row for row in c.execute('SELECT * FROM stocks ORDER BY price')]