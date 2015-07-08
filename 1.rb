require "mysql"
require_relative "2"
#module db
USER = DatabaseConfig::DATABASE_USER
PASSWORD = DatabaseConfig::DATABASE_PASSWORD
HOST = DatabaseConfig::DATABASE_HOST
DATABASE = DatabaseConfig::DATABASE_KALKUN

# TIPE SMS
TYPE_DOKTER = 1
TYPE_LAB = 2
TYPE_PASIEN = 3
TYPE_OTHER = 4 #possible? / to check wrong query

# STATUS SMS
STATUS_SUCCESS = 1
STATUS_FAIL = 0
STATUS_OTHER = -1 #possible? / to check wrong matching

def getDataFromSMS()
     begin
          smss,i = {},0
          con = Mysql.new HOST,USER,PASSWORD,DATABASE
          rs = con.query("SELECT ID,GROUP_CONCAT(TextDecoded SEPARATOR '') as texts, Status FROM sentitems GROUP BY ID Having texts like 'Yth. %' ;")
          rs.each do |x|
               i+=1
               smss["#{i}"] = {"id" => x[0], "texts" => x[1] , "status" => x[2]}
          end

     rescue Mysql::Error => e
          puts e.errno
          puts e.error

     ensure
          con.close if con
          return smss
     end          
end

def testFunction()
     puts "Ini test Function"
     smss,i = {},0
     while i < 100 do
          smss["#{i}"] = {i*90 => "HUZZAA"}
          i+=1
     end

     return smss

end

#puts testFunction()
puts getDataFromSMS()

#end