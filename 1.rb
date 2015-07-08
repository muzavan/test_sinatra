require "mysql"
require  "json"
require_relative "2"
module Database
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

     def self.getDataFromSMS()
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

     def self.testFunction()
          puts "Ini test Function"
          smss,i = {},0
          while i < 100 do
               smss["#{i}"] = {i*90 => "HUZZAA"}
               i+=1
          end

          return smss

     end

     def self.getType(sms)
          #using REGEX
          if (sms =~ /^Yth\. Dokter/) then
               return TYPE_DOKTER
          elsif (sms =~ /-PT ISI$/) then
               return TYPE_LAB
          elsif (sms =~ /-Inovasi Sehat Indonesia$/) then
               return TYPE_PASIEN
          else
               return TYPE_OTHER
          end
                 
     end

     def self.getStatus(status)
          if status == "SendingOKNoReport" then
               return STATUS_SUCCESS
          elsif status == "SendingError" then
               return STATUS_FAIL
          else
               return STATUS_OTHER 
          end
     end

     def self.getStatusCount()
          hsl = getDataFromSMS()
          counts = {}
          counts[TYPE_DOKTER] = {}
          counts[TYPE_PASIEN] = {}
          counts[TYPE_LAB] = {}
          counts[TYPE_OTHER] = {}
          counts[TYPE_DOKTER][STATUS_SUCCESS] = 0
          counts[TYPE_DOKTER][STATUS_FAIL] = 0
          counts[TYPE_DOKTER][STATUS_OTHER] = 0
          counts[TYPE_PASIEN][STATUS_SUCCESS] = 0
          counts[TYPE_PASIEN][STATUS_FAIL] = 0
          counts[TYPE_PASIEN][STATUS_OTHER] = 0
          counts[TYPE_LAB][STATUS_SUCCESS] = 0
          counts[TYPE_LAB][STATUS_FAIL] = 0
          counts[TYPE_LAB][STATUS_OTHER] = 0
          counts[TYPE_OTHER][STATUS_SUCCESS] = 0
          counts[TYPE_OTHER][STATUS_FAIL] = 0
          counts[TYPE_OTHER][STATUS_OTHER] = 0

          hsl.each do |x|
               #puts x[1]['texts'] why x[1] ?
               tipe = getType(x[1]["texts"].to_s)
               status = getStatus(x[1]["status"].to_s)
               counts[tipe][status]+=1
          end

          result = {}
          result['dokter'] = {}
          result['pasien'] = {}
          result['lab'] = {}
          result['other'] = {}
          result['dokter']['success'] = counts[TYPE_DOKTER][STATUS_SUCCESS]
          result['dokter']['fail'] = counts[TYPE_DOKTER][STATUS_FAIL]
          result['dokter']['other'] = counts[TYPE_DOKTER][STATUS_OTHER]
          result['pasien']['success'] = counts[TYPE_PASIEN][STATUS_SUCCESS]
          result['pasien']['fail'] = counts[TYPE_PASIEN][STATUS_FAIL]
          result['pasien']['other'] = counts[TYPE_PASIEN][STATUS_OTHER]
          result['lab']['success'] = counts[TYPE_LAB][STATUS_SUCCESS]
          result['lab']['fail'] = counts[TYPE_LAB][STATUS_FAIL]
          result['lab']['other'] = counts[TYPE_LAB][STATUS_OTHER]
          result['other']['success'] = counts[TYPE_OTHER][STATUS_SUCCESS]
          result['other']['fail'] = counts[TYPE_OTHER][STATUS_FAIL]
          result['other']['other'] = counts[TYPE_OTHER][STATUS_OTHER]

          return result
     end

     def self.getStatusCountAPI()
          return JSON.generate(getStatusCount())
     end

     #puts testFunction()
     #puts getDataFromSMS()

end