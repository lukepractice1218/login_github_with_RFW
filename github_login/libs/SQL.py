import json
import datetime
import cx_Oracle
import time
import re
import pprint



class SQL:

    def __init__(self,connect_string):
        self.connect_string=connect_string.replace("\',\'","/",1).replace("\',\'","@",1).replace("\'","")
        self.db = cx_Oracle.connect(self.connect_string)
        self.cursor = self.db.cursor()

    def conver_time_to_epoch(self,datetime_obj,with_time_zone=None):
        if with_time_zone==True:
            epoch=int((datetime_obj-datetime.datetime.utcfromtimestamp(0)).total_seconds()*1000+18000000)-46800000
        else:            
#             epoch=int((datetime_obj-datetime.datetime(1970, 1, 1, 0, 0,0)).total_seconds()*1000+14400000)#server timezone is lower than UTC for 4hrs(14400000)
            epoch=int((datetime_obj-datetime.datetime(1970, 1, 1, 0, 0,0)).total_seconds()*1000+18000000)#server timezone is lower than UTC for 4hrs(14400000)
        return epoch

    def get_max_value(self,column,table):
        self.db = cx_Oracle.connect(self.connect_string)
        self.cursor = self.db.cursor()
        get_max_value_query="SELECT max(column) FROM table "
        self.cursor.execute(get_maxc_value_query.replace("column",column).replace("table",table))
        result = self.cursor.fetchall()
        return int(result[0][0])
        

    def map_query_result_and_model(self,model,query_command):
        dic=[]
        self.cursor.execute(query_command)
        dbtypelist=[re.findall("\.(.*)\'",str(i[1]))[0] for i in self.cursor.description]
        result = self.cursor.fetchall()
        strmodel=str(model)    
        columns=[i[0] for i in self.cursor.description]
        print columns
        for i in result:
            strmodelcopy=strmodel
            for j in columns:
                unit=i[columns.index(j)]
                if type(unit)==int:
                    strmodelcopy=strmodelcopy.replace('\''+j+'\'',str(unit))
                elif type(unit) == datetime.datetime:
                    dbtype = dbtypelist[columns.index(j)] 
                    if dbtype=="DATETIME":
                        strmodelcopy=strmodelcopy.replace('\''+j+'\'',str(self.conver_time_to_epoch(unit)))
                    else: 
                        strmodelcopy=strmodelcopy.replace('\''+j+'\'',str(self.conver_time_to_epoch(unit,True)))
                elif type(unit)==float and str(unit)[-2:]==".0":
                    strmodelcopy=strmodelcopy.replace('\''+j+'\'',str(int(unit)))
                elif type(unit)==float and str(unit)[-2:]!=".0":
                    strmodelcopy=strmodelcopy.replace('\''+j+'\'',str(unit))
                elif type(unit)==str:
                    strmodelcopy=strmodelcopy.replace('\''+j+'\'','\''+str(unit)+'\'')
                elif unit==None:                
                    strmodelcopy=strmodelcopy.replace('\''+j+'\'',"None")
                else:
                    print "*WARN* type of "+str(type(unit))+" is not handled"
            eachdata=eval(strmodelcopy)
            dicremovenone={}        
            for i in eachdata:
                if eachdata[i]!=None:
                    dicremovenone.update({i:eachdata[i]})
            dic.append(dicremovenone)
        return dic,result          

    def simple_compare(self,a,b):
        if a==b:
            print "*HTML* 2 objects is the same"
        else:
            raise Exception(str(a)+" and "+str(b)+' Not match')         


    def compare_list_of_json_response_with_database(self,model,query_command,responseList):
        dic,result=self.map_query_result_and_model(model,query_command)
        strresponselist=[]
        for i in responseList:
            strresponselist.append(eval(str(i)))    
        if strresponselist==dic:
            print "*HTML* response from server: "+pprint.pformat(strresponselist, indent=4)
            print "*HTML* value from db: "+pprint.pformat(result, indent=4)
            print "*HTML* wrapped db values: "+pprint.pformat(dic, indent=4)
        else:
            print "*HTML* response from server: "+pprint.pformat(strresponselist, indent=4)
            print "*HTML* value from db: "+pprint.pformat(result, indent=4)
            print "*HTML* wrapped db values: "+pprint.pformat(dic, indent=4)
            print "=============================== see the difference below ===================================================== "
            for i in range(len(dic)):
                if strresponselist[i]!=dic[i]:                
                    print "*HTML* the difference- API response:\n"+pprint.pformat(strresponselist[i], indent=4)
                    print "*HTML* the difference- wrapped data:\n"+pprint.pformat(dic[i], indent=4)
                print "----------------------------------------------------------------------------------------------------------- "
            raise Exception('Json response does not match the values from database') 

    def compare_json_response_with_database(self,model,query_command,response):
        dic,result=self.map_query_result_and_model(self,model,query_command)
        dicremovenone=dic[0]
        if dicremovenone==response:
            print "*HTML* response from server: "+pprint.pformat(response, indent=4)
            print "*HTML* value from db: "+pprint.pformat(result, indent=4) 
            print "*HTML* wrapped db values: "+pprint.pformat(dicremovenone, indent=4)
        else:
            print "*HTML* response from server: "+pprint.pformat(response, indent=4)
            print "*HTML* value from db: "+pprint.pformat(result, indent=4)
            print "*HTML* wrapped db values: "+pprint.pformat(dicremovenone, indent=4)
            print "=============================== see the difference below ===================================================== "
            for i in response:
                if response[i]!=dicremovenone[i]:    
                    print "*HTML* the difference- API response:\n"+pprint.pformat(response[i], indent=4) 
                    print "*HTML* the difference- wrapped data:\n"+pprint.pformat(dicremovenone[i], indent=4)
                print "----------------------------------------------------------------------------------------------------------- "
            raise Exception('Json response does not match the values from database') 

    def execute_none_select_sql_command(self,command):
        self.cursor.execute(command)
        self.db.commit()

    def execute_select_sql_command(self,command):
        self.cursor.execute(command)
        result = self.cursor.fetchall()
        return result



    def prepare_the_data_files(self,rows):#file_receipt_tracking
        filekeys=[]
        for i in range(rows):
            filekey_17= "4000"+str(time.time()).replace(".","")+"9"
            orig_abf_name_18="30200"+str(time.time()).replace(".","")+"9"
            register_name_num18="402000"+str(time.time()).replace(".","")
            maxid=self.execute_select_sql_command("select max(ID) from \"PRINT_DEV\".\"FILE_RECEIPT_DETAIL\"")
            insert_rows_into_date_files_table="""INSERT INTO "PRINT_DEV"."DATA_FILES" (CLIENT_LAYOUT, FILE_KEY, ORIG_NAME, ABF_NAME, IMPORT_DATE, RECEIVED, STATE, OVERRIDE, CREATED_BY, CREATED_DT, UPDATED_BY, UPDATED_DT, REGISTER_NAME) VALUES ('4000148', '%s', '%s.txt', '%s.txt', TO_DATE('2017-02-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2017-02-18 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '3', '0', 'user', TO_DATE('2017-02-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'elvis', TO_DATE('2017-02-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '%s.txt')"""%(filekey_17,orig_abf_name_18,orig_abf_name_18,register_name_num18)
            insert_rows_into_date_file_receipt_detail="""INSERT INTO "PRINT_DEV"."FILE_RECEIPT_DETAIL" (FILE_KEY, ID, GROUP_KEY, NUM_WHITE, NUM_CHECKS, TOTAL_CHECKS) VALUES ('%s', '%d', 'LMS_EOR', '1737', '888', '888')"""%(filekey_17,maxid[0][0]+1)
            self.execute_none_select_sql_command(insert_rows_into_date_files_table)
            self.execute_none_select_sql_command(insert_rows_into_date_file_receipt_detail)
            filekeys.append(filekey_17)
        return  filekeys

    def delete_the_data_files(self,filekeys):#file_receipt_tracking
        for i in filekeys:
            self.execute_none_select_sql_command("""DELETE FROM "PRINT_DEV"."FILE_RECEIPT_DETAIL" WHERE FILE_KEY=%s"""%(i))
            self.execute_none_select_sql_command("""DELETE FROM "PRINT_DEV"."DATA_FILES" WHERE FILE_KEY=%s"""%(i))

    def get_passowrd_of_test_user(self):#security_manager    
        get_pwd="""SELECT PASSWORD FROM "USER" WHERE USER_ID = 'Elvis77' """
        pwd=self.execute_select_sql_command(get_pwd)
        return  pwd[0][0]

    def prepare_data_for_multi_level(self, action, level):#Document mgr
        DOC_ID = '8787878787'
        #select action
        if action == 'hold': action_sql = ['LAST_HOLD_ID', 'NULL']
        elif action == 'release': action_sql = ['LAST_HOLD_ID', 8787]
        else : action_sql = ['RELEASE_DATE', '''TO_DATE('2099-02-22', 'YYYY-MM-DD')''']
        
        #select level
        if level == 'auto': level_sql = ['MANAGEMENT_LEVEL', 1]
        elif level == 'file': level_sql = ['MANAGEMENT_LEVEL', 2]
        else : level_sql = ['MANAGEMENT_LEVEL', 3]

        # print "*WARN*"+str(action_sql)
        # print "*WARN*"+str(level_sql)
        
        insert_string = """insert into docindex_dev.DOCUMENT_DECISION(DOC_ID, DOC_NAME, IMPORT_DATE, DOCUMENT_TYPE, CLAIM_TYPE, RECIPIENT_TYPE, GROUP_ID, GROUP_NAME, TRANSACTION_ID, CLIENT_LAYOUT, %s, %s)values(%s, 87, TO_DATE('2018-03-15 00:00:01', 'YYYY-MM-DD HH24:MI:SS'), 02, 03, 02, 8787, 'Yo', 87878787, 8787, %s, %d)"""%(action_sql[0], level_sql[0], DOC_ID, action_sql[1], level_sql[1])
        # print "*WARN*"+str(insert_string)
        self.execute_none_select_sql_command(insert_string)
        self.execute_none_select_sql_command("""insert into docindex_dev.DOCUMENT_CHECK(DOC_ID)values(%s)"""%(DOC_ID))
        self.execute_none_select_sql_command("""insert into docindex_dev.DOCUMENT_COPY(DOC_ID, COPY_NUMBER)values(%s, '8888')"""%(DOC_ID))

    def delete_data_for_multi_level(self):#Document mgr
        DOC_ID = '8787878787'
        self.execute_none_select_sql_command("""delete from DOCUMENT_COPY where DOC_ID = %s"""%(DOC_ID))
        self.execute_none_select_sql_command("""delete from DOCUMENT_DECISION where DOC_ID = %s"""%(DOC_ID))
        self.execute_none_select_sql_command("""delete from DOCUMENT_CHECK where DOC_ID = %s"""%(DOC_ID))

    def unilize_time(self,table,time,*columeList):
        #time format "2018-03-15"
        unilize_time="""UPDATE %s SET"""%(table)+" "+str(columeList).replace(",)",")").replace("(u'","").replace("')"," = TO_DATE('%s 00:00:00', 'YYYY-MM-DD HH24:MI:SS')"%(time)).replace("', u'"," = TO_DATE('%s 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), "%(time))
        self.execute_none_select_sql_command(unilize_time)
            

    def close_sql_connection(self):
        self.db.close()












