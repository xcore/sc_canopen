#---------------------------------
#Data Types Suppoted in CANOpen
#---------------------------------
# bool 		- 0x0001 - 1 byte
# domain        - 0x000f - 8 bytes //not sure
# int16 	       - 0x0003 - 2 bytes
#int24		- 0x0010 - 3 bytes
#int32		- 0x0004 - 4 bytes
#int40		- 0x0012 - 5 bytes
#int48		- 0x0013 - 6 byes
#int56		- 0x0014 - 7 bytes
#int64		- 0x0015 - 8 bytes
#int8		- 0x0002 - 1 byte
#octec string	  - 0x000A - strlen
#Real32		- 0x0008 - 4 bytes
#Real64		- 0x0011 - 8 bytes
#time_diff	     - 0x000d - 8 bytes //not sure
#time_of_day	   - 0x000c - 8 bytes //not sure
#unicode string - 0x000b - strlen
#unsigned16	    - 0x0006 - 2 bytes
#unsigned24	    - 0x0016 - 3 bytes
#unsigned32	    - 0x0007 - 4 bytes
#unsigned40	    - 0x0018 - 5 bytes
#unsigned48	    - 0x0019 - 6 bytes
#unsigned56	    - 0x001A - 7 bytes
#unsigned64	    - 0x001B - 8 bytes
#unsigned8	     - 0x0005 - 1 byte
#Vis string	    - 0x0009 - strlen
#----------------------------------

print '\n'
print "#"*42
print "# Welcome to Object Dictionary Generator #"
print "#"*42
print '\n'
NODE_ID = raw_input(" Enter Node ID of CANOpen Device : ")
print '\n'

data_types=['0x0001','0x0002','0x0005', '0x0003','0x0006','0x0010','0x0016','0x0004','0x0008','0x0007','0x0012','0x0018','0x0013','0x0019','0x0014','0x001a','0x000f','0x0015','0x0011','0x000d','0x00c','0x001b','0x000a','0x000b','0x0009']

od_index = {}
od_si = {}
od_access = {}
od_data = {}

co_od_index=[]
co_od_si=[]

for values in data_types:
  od_index[values]=[]
  od_si[values]=[]
  od_access[values]=[]
  od_data[values]=[]
try:  
  fp=open("CO_EDS_401.eds")
except:
  print 'Error!, Name of file should be "CO_EDS_401.eds"\n'
for line in fp:
  if(line.find("[") == 0):
    index = line.replace('[','').replace(']\n','')
    if(index.find("sub") == 4):
      index,si = index.split('sub')
    else:
      si = -1  
  if(line.find("DataType") == 0):
   line = line.replace("DataType=",'').replace('\n','')
   dtype = line
  
  if(line.find("AccessType") == 0):
    line = line.replace("AccessType=",'').replace('\n','')
    atype = line
    
  if(line.find("DefaultValue") == 0):
    line = line.replace("DefaultValue=",'').replace('\n','')
    od_data[dtype].append(line)
    od_index[dtype].append(index)
    od_si[dtype].append(si)
    od_access[dtype].append(atype)
    co_od_index.append(index)
    co_od_si.append(si)
    
length = []
required_data_type=[]
final_data=[]
final_index=[]
final_si=[]
final_acs=[]
mapping = []
for data in data_types:
  if(len(od_data[data]) != 0):
    final_data+=(od_data[data])
    final_index+=(od_index[data])
    final_si+=(od_si[data])
    final_acs+=(od_access[data])
    length.append(len(od_data[data]))
    required_data_type.append(data)
    
total_dtypes = len(required_data_type)

finally_required_data=[]
value=0
byte_length=0
mapping.append(0)
for counter in range(0 ,len(final_data)):
  if(counter == length[value]):
    value+=1
    length[value]=length[value]+length[value-1]
    
  if(final_data[counter].find("$NODEID") >= 0):
     final_data[counter] = final_data[counter].replace("$NODEID",'')
     final_data[counter] = long(final_data[counter],16)+long(NODE_ID )
  try:
    final_data[counter] = hex(int(final_data[counter]) & 0xffffffffffffffff)
  except:
    final_data[counter]=final_data[counter]
     
  if(required_data_type[value] == '0x0001'):
    finally_required_data.append(final_data[counter])
    byte_length+=1
  elif(required_data_type[value] == '0x0002'):
    finally_required_data.append(final_data[counter])
    byte_length+=1
  elif(required_data_type[value] == '0x0005'):
    finally_required_data.append(final_data[counter])
    byte_length+=1
  elif(required_data_type[value] == '0x0003'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00) >>8)
    byte_length+=2
  elif(required_data_type[value] == '0x0006'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    byte_length+=2
  elif(required_data_type[value] == '0x0010'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    byte_length+=3
  elif(required_data_type[value] == '0x0016'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000)>>16)
    byte_length+=3
  elif(required_data_type[value] == '0x0004'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    byte_length+=4
  elif(required_data_type[value] == '0x0008'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000)>>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    byte_length+=4
  elif(required_data_type[value] == '0x0007'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000)>>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    byte_length+=4
  elif(required_data_type[value] == '0x0012'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000)>>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    byte_length+=5
  elif(required_data_type[value] == '0x0018'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    byte_length+=5
  elif(required_data_type[value] == '0x0013'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    byte_length+=6
  elif(required_data_type[value] == '0x0019'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    byte_length+=6
  elif(required_data_type[value] == '0x0014'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000000000)>>48)
    byte_length+=7
  elif(required_data_type[value] == '0x001a'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000000000)>>48)
    byte_length+=7
  elif(required_data_type[value] == '0x000f'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000000000)>>48)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000000000)>>56)
    byte_length+=8
  elif(required_data_type[value] == '0x0015'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000000000)>>48)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000000000)>>56)
    byte_length+=8
  elif(required_data_type[value] == '0x0011'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000000000)>>48)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000000000)>>56)
    byte_length+=8
  elif(required_data_type[value] == '0x000d'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000000000)>>48)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000000000)>>56)
    byte_length+=8
  elif(required_data_type[value] == '0x000c'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000000000)>>48)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000000000)>>56)
    byte_length+=8
  elif(required_data_type[value] == '0x001b'):
    finally_required_data.append((long(final_data[counter],16)&0xFF))
    finally_required_data.append((long(final_data[counter],16)&0xFF00)>>8)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000) >>16)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000)>>24)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>32)
    finally_required_data.append((long(final_data[counter],16)&0xFF00000000)>>40)
    finally_required_data.append((long(final_data[counter],16)&0xFF0000000000)>>48)
    finally_required_data.append((long(final_data[counter],16)&0xFF000000000000)>>56)
    byte_length+=8
  elif(required_data_type[value] == '0x000a'):
    for letter in final_data[counter]:
      finally_required_data.append("'"+letter+"'")
    byte_length+=len(final_data[counter])
  elif(required_data_type[value] == '0x000b'):
    for letter in final_data[counter]:
      finally_required_data.append("'"+letter+"'")
    byte_length+=len(final_data[counter])
  elif(required_data_type[value] == '0x0009'):
    for letter in final_data[counter]:
      finally_required_data.append("'"+letter+"'")
    byte_length+=len(final_data[counter])
  mapping.append(byte_length)
mapping.pop()

sub_index_pointer=[]
access_mapping_parameter=[]
for d in range(0,len(co_od_index)):
  for l in range(0,len(final_index)):
    if(co_od_index[d] == final_index[l]):
      if(co_od_si[d] == final_si[l]):
        sub_index_pointer.append(mapping[l])
        access_mapping_parameter.append(final_acs[l])

#print finally_required_data[mapping[final_index.index('1008')-1]]

required_index_value = []
index_pointer = []
for d in range(0,len(co_od_si)):
  if((co_od_si[d] == '0') or (co_od_si[d] == -1)):
    required_index_value.append(co_od_index[d])
    index_pointer.append(d)
  
od_length_list=[]
for lol in range(0,len(required_index_value)):
  if required_index_value[lol] in required_index_value:
    temp_lisst = [x for x in co_od_index if x==required_index_value[lol]]
  od_length_list.append( len(temp_lisst))
  
NUMBER_OF_OBJECTS = 0
for lol in range(0,len(co_od_index)):
  try:
    if((int(co_od_si[lol]) == 0 ) or (int(co_od_si[lol]) == -1)):
      if co_od_index[lol] in co_od_index:
        temp_lisst = [x for x in co_od_index if x==co_od_index[lol]]
        NUMBER_OF_OBJECTS +=1
  except:
    if((int(co_od_si[lol],16) == 0 ) or (int(co_od_si[lol],16) == -1)):
      if co_od_index[lol] in co_od_index:
        temp_lisst = [x for x in co_od_index if x==co_od_index[lol]]
        NUMBER_OF_OBJECTS +=1

address_pointer_to_file=[]
address_length_to_file=[]
total_length_i_need = 0
address_pointer_to_file.append(0)
for data in required_data_type:
  if((data == '0x0009') or (data == '0x000b') or (data == '0x000a')):
    for values in od_data[data]:
      total_length_i_need+=len(values)
      address_pointer_to_file.append(total_length_i_need)
      address_length_to_file.append(len(values))
  elif((data == '0x0001') or (data == '0x0002') or (data == '0x0005')):
    total_length_i_need+=len(od_index[data])
    address_pointer_to_file.append(total_length_i_need)
    address_length_to_file.append('1')
  elif((data == '0x0003') or (data == '0x0006')):
    total_length_i_need+=len(od_index[data])*2
    address_pointer_to_file.append(total_length_i_need)
    address_length_to_file.append('2')
  elif((data == '0x0010') or (data == '0x0016')):
    total_length_i_need+=len(od_index[data])*3
    address_pointer_to_file.append(total_length_i_need)
    address_length_to_file.append('3')
  elif((data == '0x0004') or (data =='0x0008') or (data == '0x0007')):
    total_length_i_need+=len(od_index[data])*4
    address_pointer_to_file.append(total_length_i_need)
    address_length_to_file.append('4')
  elif((data == '0x0012') or (data == '0x0018')):
    total_length_i_need+=len(od_index[data])*5
    address_pointer_to_file.append(total_length_i_need)
    address_length_to_file.append('5')
  elif((data == '0x0013')or(data == '0x0019')):
    total_length_i_need+=len(od_index[data])*6
    address_pointer_to_file.append(total_length_i_need)
    address_length_to_file.append('6')
  elif((data == '0x0014') or ('0x001a')):
    total_length_i_need+=len(od_index[data])*7
    address_pointer_to_file.append(total_length_i_need)
    address_length_to_file.append('7')
  elif((data == '0x000f') or (data == '0x0015') or (data == '0x0011') or (data == '0x000d') or (data == '0x00c') or (data == '0x001b')):
    total_length_i_need+=len(od_index[data])*8
    address_pointer_to_file.append(total_length_i_need)
    address_length_to_file.append('8')  
address_pointer_to_file.pop() 


file_ptr = open("object_dictionary.h",'w')
file_ptr.write('#ifndef OBJECT_DICTIONARY_H_\n')
file_ptr.write('#define OBJECT_DICTIONARY_H_\n\n#include "common.h"\n\n')
file_ptr.write("#define NUMBER_OF_OBJECTS "+str(NUMBER_OF_OBJECTS)+"\n")
file_ptr.write("#define NUMBER_OF_SUBINDEX_POINTERS "+str(len(co_od_si))+"\n")
file_ptr.write("#define NUMBER_OF_DATA_BYTES "+str(len(finally_required_data))+"\n")
file_ptr.write("#define OFFSETS_OF_SUBINDEX_LENGTH "+str(len(address_length_to_file))+"\n\n")
file_ptr.write("// This is an Auto generated file. Do not edit this file.\n\n")
file_ptr.write("typedef struct subindex_size\n{\n")
file_ptr.write("  void * address;\n  unsigned size;\n}subindex_size;\n\n")
file_ptr.write("typedef struct object\n{\n  unsigned short addr;\n  unsigned short subindex_count;\n")
file_ptr.write("  void **subindex_data;\n  void *access_pointer;\n} object;\n\n")
#file_ptr.write("enum access {\n  RO    = 0,\n  WO    = 1,\n  RW     = 2,\n  RWR   = 3,\n  RWW   = 4,\n  CONST = 5\n};\n\n")
file_ptr.write("unsigned char data[NUMBER_OF_DATA_BYTES] = {")

for data in range(0,len(finally_required_data)):
  if(data % 10 == 0):
    file_ptr.write("\n")
  if(data == (len(finally_required_data)-1)):
    file_ptr.write(" %4s\n"%str(finally_required_data[data]).replace('L',''))
    file_ptr.write("};\n\n\n")
  else:
    file_ptr.write(" %4s,"%str(finally_required_data[data]).replace('L',''))

file_ptr.write("void * subindex_pointers[NUMBER_OF_SUBINDEX_POINTERS] = {")
for  data in range(0,len(sub_index_pointer)):
  if(data % 5 == 0):
    file_ptr.write("\n")
  if(data == (len(sub_index_pointer)-1)):
    file_ptr.write(" &data[0]+")
    file_ptr.write("%4s\n"%str(sub_index_pointer[data]))
    file_ptr.write("};\n\n\n")
  else:
    file_ptr.write(" &data[0]+")
    file_ptr.write("%4s,"%str(sub_index_pointer[data]))

file_ptr.write("unsigned char access_type[NUMBER_OF_SUBINDEX_POINTERS] = {")
for  data in range(0,len(access_mapping_parameter)):
  if(data % 5 == 0):
    file_ptr.write("\n")
  if(data == (len(access_mapping_parameter)-1)):
    file_ptr.write("%5s"%access_mapping_parameter[data].upper())
    file_ptr.write("\n};\n\n")
  else:
    file_ptr.write("%5s"%access_mapping_parameter[data].upper()+', ')

file_ptr.write("object object_dict[NUMBER_OF_OBJECTS] = {\n")
for lol in range(0,len(co_od_index)):
  try:
    if((int(co_od_si[lol]) == 0 ) or (int(co_od_si[lol]) == -1)):
      if co_od_index[lol] in co_od_index:
        temp_lisst = [x for x in co_od_index if x==co_od_index[lol]]
        NUMBER_OF_OBJECTS +=1
        file_ptr.write('{0x'+co_od_index[lol]+', '+str(len(temp_lisst))+', '+'&subindex_pointers[0] + '+str(lol)+','+' &access_type[0] + '+str(lol)+'},\n ')
  except:
    if((int(co_od_si[lol],16) == 0 ) or (int(co_od_si[lol],16) == -1)):
      if co_od_index[lol] in co_od_index:
        temp_lisst = [x for x in co_od_index if x==co_od_index[lol]]
        NUMBER_OF_OBJECTS +=1
        file_ptr.write('{0x'+co_od_index[lol]+', '+str(len(temp_lisst))+', '+'&subindex_pointers[0] + '+str(lol)+','+' &access_type[0] + '+str(lol)+'},\n ')
file_ptr.write("};\n\n\n")

file_ptr.write("subindex_size subindex_size_data[OFFSETS_OF_SUBINDEX_LENGTH] = {\n")
for data in range(0,len(address_length_to_file)):
  if(data != (len(address_length_to_file)-1)):
    file_ptr.write("{ &data[%3s], %3s},\n"%(str(address_pointer_to_file[data]),str(address_length_to_file[data])))
  else:
    file_ptr.write("{ &data[%3s], %3s}\n"%(str(address_pointer_to_file[data]),str(address_length_to_file[data])))
    file_ptr.write("};\n")
file_ptr.write("\n#endif")
file_ptr.close()

print '"object_dictionary.h" file generated succesfully !!'
print '\n'
