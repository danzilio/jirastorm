#!/usr/bin/ruby
# jira_to_stormboard.rb
#
#first attempt to:
#  run a specific jira query for stories from OPG backlog
#   write them out to a stormboard
# JAC
#
#Sept 9, 2015 - a verion that tries to talk to stormboard
# Sept 20 - first attempt to wire it together

print "\n\n===================\n"
print     " Jira to Stormboard \n"
print     "==================="
time1 = Time.now
puts "\nStart Time : " + time1.inspect


##   Bring out your gems ##
begin
require 'pp'
require 'rubygems'
require 'rest-client'
require 'json'
require 'ostruct'
require 'io/console'
require 'highline/import'
require 'logger'
require 'net/http'
require 'net/https'
rescue LoadError => e

	friendly_ex = e.exception('*****  Well... it looks like one of the gems did not load, exiting  ******')
	friendly_ex.set_backtrace(e.backtrace)
	raise friendly_ex
end

#
# using logger
#
#  note the log file name is set right here
#  and overwrites on each run!
#  (no sense in making files that never clean up for
#  something like this
#
class MyLog
# Logging levels:
	# find some info on this here http://www.sitepoint.com/rubyists-love-logging/
	# UNKNOWN – I can’t even. Always written to log.
	# FATAL – Fatal errors and other serious unhappiness.
	# ERROR – An error occurred. Someone should fix this.
	# WARN – A possible error occurred. Someone maybe should fix this.
	# INFO – In case you were wondering…
	# DEBUG – The more sophisticated version of puts style debugging.
	#
       def self.log
	       if @logger.nil?
#		       @logger = Logger.new STDOUT
			@logger = Logger.new 'stormboard_load.log'
#		      	@logger.level = Logger::DEBUG
		      	@logger.level = Logger::INFO
		      	@logger.datetime_format = '%Y-%m-%d %H:%M:%S '
	       end
	       @logger
       end
end  # MyLog class


#######################################
#
#  read_key
#
#read in the api key from passed filename
########################################
def read_key(filename)
begin
	begin
	MyLog.log.info "Reading key from #{filename}"
	read_key=open(filename).gets.chomp
	rescue
		print "\n\n ERROR: could not open api key file #{fname} \n You can't do much without an API key \nBailing out\n"
		Mylog.log.fatal "Couldn't read the API key file #{fname} - exiting"
		exit 1
	end
	keyforlogging=read_key.byteslice(1..3) + "******.."
	MyLog.log.info "Read Key #{keyforlogging}"
	return read_key
end
end  # read_key

#######################################
#
#  read_jira
#
# make the REST call to jira to get the items
# note it is limited to 50 (which is fine for this)
#######################################
def read_jira(jira_url)
	begin
	MyLog.log.info "Making call to jira #{jira_url}"
	local_response = RestClient.get "#{jira_url}"
	MyLog.log.debug "Jira response" + local_response
	rescue => e
		print "\n ERROR IN CONNECTING TO JIRA\n"
		e.response
	end
	return local_response
end # read_jira


############################
#
# get_storms
#
# get the list of stormboards
# that you own
# ###########################

def get_storms(url, header_set)
	begin
		begin
			local_response =RestClient.get "#{url}", header_set
		rescue => e
			print "\n\n ERROR IN CONNECTING TO STORMBOARD\n"
			MyLog.log.fatal "ERROR: Couldn't connect to stormboard"
			MyLog.log.fatal e.response
			exit
		end
	MyLog.log.info "get_storms routine received list of storms"
	MyLog.log.debug "storm list from get_storms:" + local_response
	return local_response

	end
end  #get_storms



#######################################
#
#  pick_storm
#
#read in the api key from passed filename
########################################
def pick_storm(storm_array)
	begin
	newest_storm=0
	newest_storm_date=storm_array[0].lastactivity
	print "\n\n============================== \n\n"
	print    "Select Storm to add items to:"
	storm_array.each_index do |index|
		current_issue=storm_array[index]
		if current_issue.lastactivity > newest_storm_date then
			newest_storm=index
		end if
		MyLog.log.debug "Storm Name " + current_issue.title
		MyLog.log.debug "Storm Id " + current_issue.id
		print "\n["
		print index
		print "] "
		print current_issue.title," Last Activity: ",current_issue.lastactivity, " id:",current_issue.id," key:",current_issue.key
	end
	newest_storm_title=storm_array[newest_storm].title
	print "\n\nNewest issue is: " + newest_storm_title , "\n"
	MyLog.log.debug "Newest Storm is " +  newest_storm_title
	MyLog.log.debug "about to get selection to add to storm"
	numitems=storm_array.length
	$i=0
	choices=""
	until $i >= numitems
		choices=choices + "|" + $i.to_s
		$i+=1;
	end
	answer = ask("Your choice [#{choices}]? ") do |q|
	end

	say("Your choice: #{answer}")
	answer_int=answer.to_i
	if answer_int >= numitems or answer_int < 0 then
		print "ERROR: You didn't pick a valid answer\n Exit(1)\n"
		MyLog.log.fatal "Bad selection - no retry logic so exiting"
		MyLog.log.fatal "Selection was: " + answer
		exit 1
	end
	MyLog.log.info "Item picked is " + answer + " which is " + storm_array[answer_int].title
	print "You picked: " + storm_array[answer_int].title ,"\n"
	return answer_int
end
end  #pick_storm



#######################################
#
#  write_item
#
# make the magic happen - write an item to the stormboard
########################################
def write_item(create_item_url,local_api_key,stormid,text_value,x_value,y_value)
	begin
#make the hash to store the json for the item we are adding
#FYI I think this is passed as a JSON body, so headers2 is a bit misleading
	headers2 =Hash.new
	#headers2.store("stormid","205006")
	headers2.store("stormid",stormid)
	headers2.store("type", "text")
	headers2.store("data", text_value )
	headers2.store("x",x_value)
	headers2.store("y",y_value)
	item_json = headers2.to_json
	MyLog.log.debug "the json to add the item is #{item_json}"
## needed to use the Net::HTTP stuff here, as I couldn't figure out how to get the RestClient to work with a JSON body payload and a header -  I kept getting an error back so I went in a new direction
#the curl command is:
#curl -i -X POST -H "X-API-Key:yourverylongapikey here"  -H "Content-type:application/json" -d '{"stormid": "205006","type": "text","data": "test issue 4","x": "100","y":"1120"}'  https://api.stormboard.com/ideas
	MyLog.log.info "About to make the create item call"
	MyLog.log.debug "JSON:" + item_json
	uri=URI.parse(create_item_url)
	https = Net::HTTP.new(uri.host,uri.port)
	https.use_ssl = true
	req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
	req['X-API-Key'] = local_api_key
	req.body=item_json
	begin
		res=https.request(req)
	rescue => e
		print "\n ERROR IN CONNECTING TO STORMBOARD TO ADD ITEM\n"
		MyLog.log.fatal "ERROR ADDING ITEM"
		MyLog.log.fatal e.response
		e.response

	end

	MyLog.log.debug  "Response #{res.code} #{res.message}: #{res.body}"
	response2=res
	response_code =res.code.to_i
	if response_code==200 then
		MyLog.log.info "added item #{res.body}"
	else
		MyLog.log.error "item not added - not a 200 reponse code #{res.code} #{res.message} #{res.body}"
		print "\nERROR ADDING ITEM - DIDN'T GET A 200 Response to the add - check the log file\n"
		print "Item in question is ${text_value}\n"
		return false  #I guess a true / false on the add
	end
	end
	return true  #I guess a true / false on the add
end #write_items



# *****************
#
# not sure what a main () would be in ruby, but if there
# is such a thing, this is basically it
#
#
# ******************



###############
###############
###############
# Here are the settings you might want to change
# #############
###############
###############
MyLog.log.info "Starting Up / initializing values"
jira_url = 'https://jira.roving.com//rest/api/2/search/'
jql = "?jql=project=\"OPG\" AND issuetype = \"Story\" AND status = \"Backlog\" ORDER BY Rank ASC"
jira_full_url = jira_url+jql
print "\n Jira URL/query: " + jira_full_url
jira_encoded_url = URI.encode(jira_full_url)

MyLog.log.info "The Jira query: ${jira_full_url}"
MyLog.log.debug "The encoded url ${jira_encoded_url}"
sb_url = 'https://api.stormboard.com/storms'
fname = 'sb_api.txt'
sb_create_item_url = 'https://api.stormboard.com/ideas'
sb_header_key ='X-API-Key'

# stormboard placement info and max items to add
sb_y_one=1120
sb_y_height=230
sb_x_home=40
sb_x_width=200
sb_max_add_items=36
sb_items_per_row=12

# Set the request parameters
sb_api_key=nil
sb_full_url = sb_url
MyLog.log.info  " URL TO CONNECT TO: " + sb_full_url

sb_encoded_url = URI.encode(sb_full_url)
sb_create_item_encoded_url = URI.encode (sb_create_item_url)

MyLog.log.info  "SB Encoded URL: #{sb_encoded_url}"
MyLog.log.info  "SB add item Encoded URL: #{sb_create_item_encoded_url}"


## OK - here we go ...read the api key from the file
MyLog.log.debug "filename #{fname}"
sb_api_key = read_key(fname)

sb_header_value=sb_api_key
headers =Hash.new
headers.store(sb_header_key,sb_api_key)

# connect to Jira and get the items
print "\n Connecting to Jira ...\n"
response = read_jira(jira_encoded_url)
data_hash2 = JSON.parse(response, object_class: OpenStruct)
data_hash = JSON.parse(response)
jira_issues = data_hash['issues']
jira_issues2 =data_hash2.issues
MyLog.log.info "Issues Retrieved: " + jira_issues2.length.to_s
if jira_issues2.length <3 then
	print "so...there were less than 3 items\n that doesn't seem right\n"
	print "\n NOT continuing - check the logs for more details\n"
	MyLog.log.fatal "Less than 3 items from Jira - bailing out"
	exit 1
else
	print "Issues Retrieved from Jira: " + jira_issues2.length.to_s
end  #if less than 3

## let's talk to Stormboard now...
MyLog.log.info "Making Call to Stormboard to find boards: " + sb_encoded_url
response = get_storms(sb_encoded_url, headers)
MyLog.log.info "Successful call to Stormboard to get list of storms"
MyLog.log.debug response

data_hash2 = JSON.parse(response, object_class: OpenStruct)
data_hash = JSON.parse(response)
issues = data_hash['storms']
issues2 =data_hash2.storms  # this is in an array type structure to use in the menu

# now that we have the storm boards that are owned by they key
# select one (and figure out the newest one along the way
answer_int = pick_storm(issues2)
MyLog.log.info "the picked answer " + answer_int.to_s
MyLog.log.info "StormID: " + issues2[answer_int].id



issues_to_add=0  #safety first
# figure out how many items to add - no more than max, or the number that there are
if jira_issues2.length > sb_max_add_items then
	issues_to_add=sb_max_add_items
else
	issues_to_add=jira_issues2.length
end
MyLog.log.info "Attempting to add #{issues_to_add} to stormboard"
print "\n adding items:"
#issues_to_add=2  #testing
$index = 0
#
# note: I think this creates a new https connection each time it calls write_item
# not really ideal but is a max of 36 calls with the default config...
while $index < issues_to_add
	current_issue=jira_issues2[$index]
	item_description = "[#{current_issue.key}] #{current_issue.fields.summary}   #{current_issue.fields.description}"
	base_modulo_x=$index % sb_items_per_row  #figure out which item on the line (x)
	xval= sb_x_home+(base_modulo_x*sb_x_width)
	row_num = $index / sb_items_per_row #what row are we on
	yval=sb_y_one+(row_num*sb_y_height)
	print "."
	added_item = write_item(sb_create_item_url,sb_api_key,issues2[answer_int].id,item_description,xval.to_s,yval.to_s)
	if added_item then
		MyLog.log.debug "added item #{item_description} #{current_issue.fields.summary}"
	else
		MyLog.log.error "ERROR adding item #{item_description} #{current_issue.fields.summary}"
	end

	MyLog.log.debug "KEY: #{current_issue.key} ID  #{current_issue.id} Summary: #{current_issue.fields.summary} Description: #{current_issue.fields.description}"
	$index+=1
end



time2 = Time.now
puts "\nFinish Time : " + time2.inspect
run_time = time2-time1
puts "Run time : " + run_time.inspect + " seconds (including waiting for you to mash the buttons)"
print "\n === Done  === \n\n"
MyLog.log.info "Done / exiting with a status of 0"
exit 0
