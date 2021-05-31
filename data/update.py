#!/usr/bin/python3

# loading in modules
import sqlite3
from sqlite3 import Error
import ipaddress

debug = false 

def create_con(db_file):
    con = None
    try:
        con = sqlite3.connect(db_file)
        return con
    except Error as e:
        print(e)
    return con

def create_table(con, create_sql):
    try:
        c = con.cursor()
        c.execute(create_sql)
    except Error as e:
        print(e)

def update_rentry(con,entry):
    #sql = ''' UPDATE routing SET counter = ? WHERE prefix=? AND mask=? '''
    sql = ''' REPLACE INTO routing(counter,prefix,mask) VALUES(?,?,?) '''
    cur = con.cursor()
    print (sql,entry)
    cur.execute(sql, entry)
    con.commit()
    return cur.lastrowid

def insert_rentry(con, entry):
    # inserts prefix/mask - and if already exists increaes counter
    # idea: if entry already exists 1>2
    # if all entries have been added in DB:
    #    >=2 --> Keep
    #   =1   --> Delete from Routing as Prefix has been removed from DB
    sql = ''' INSERT INTO routing(prefix,mask) VALUES(?,?) 
            ON CONFLICT(prefix,mask) DO UPDATE SET counter = counter + 1;
            '''
    cur = con.cursor()
    cur.execute(sql, entry)
    con.commit()

    return cur.lastrowid


def select_all_entry(con):
    cur = con.cursor()
    cur.execute("SELECT prefix,mask,counter from routing")
    # 0 = prefix
    # 1 = mask
    # 2 = counter

    rows = cur.fetchall()
    for row in rows:
        pre = ''

        try: 
            ipaddress.IPv4Network(row[0])
        except  (ipaddress.AddressValueError, ipaddress.NetmaskValueError, ValueError) as e:
            # suppress message
            #msg = "#Provided string is not a valid network: {}.".format(e)
            print (msg)
        else:
            if row[2]<=1:
                pre = "no "

            pre = pre + "ip route {} {} null0".format(row[0], row[1]);
            print(pre)


def main():
    # creating file path
    dbfile = 'routing.db'

    # Create a SQL connection to our SQLite database
    sql_create_table = """ CREATE TABLE IF NOT EXISTS routing (
                            id integer PRIMARY KEY AUTOINCREMENT,
                            prefix text NOT NULL,
                            mask text NOT NULL,
                            counter integer DEFAULT 1,
                            UNIQUE(prefix,mask)
                            ); 
                            """

    con = create_con(dbfile)

    if con is not None:
        # create table
        create_table(con,sql_create_table)

    else:
        print("Error! Cannot create the database connection")
        quit()


    # read 3 files and process them to create a new one :)
    # output = frr-input.new
    # dbimport.txt = what is imported from various downloadable sources
    # dbwhite.txt = whitelist (manual)
    # exist.txt = actual routing table -> can be optimized later

    blacklists = ("exist.txt","dbimport.txt")
    for bl in blacklists:
        with open(bl) as f:
            for line in f:
                line = line.strip('\n')
                prefix = line.split(" ")
                insert_rentry(con,prefix)
        f.close() 


    # whitelist
    with open('dbwhite.txt') as f:
        for line in f:
            line = line.strip('\n')
            prefix = line.split(" ")
            prefix.insert(0,"0")
            update_rentry(con,prefix)
        f.close()

    select_all_entry(con)

    # Be sure to close the connection
    con.close()

if __name__ == '__main__':
    main()


