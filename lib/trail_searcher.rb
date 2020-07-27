require 'pry'
## Is the interface for user interaction

class TrailSearcher

    def initialize
    end

    def run
        self.greeting
        self.prompt_and_display_trails
        self.get_trail_details
        user_input = ""
        until user_input == "exit" || user_input == "2"
            puts "\n**********************************************"
            puts "\nEnter '" + "1".colorize(:cyan) + "' to go back to your list of trails."
            puts "Enter '" + "2".colorize(:cyan) + "' to enter a new zip code."
            puts "Enter '" + "exit".colorize(:cyan) + "' to close this application."
            user_input = gets.chomp
            if user_input == "1"
                puts "\n"
                self.list_trails 
                self.get_trail_details
                user_input = ""
            elsif user_input == "2"
                Trail.all.clear
                self.prompt_and_display_trails 
                self.get_trail_details
                user_input = ""
            elsif user_input != "exit"
                puts "\nYour input of '#{user_input}' is invalid! Please follow the instructions below:"
            end 
        end
    end 

    def greeting
        puts "\nHello!"
        sleep 2
        puts "\nWhat is your name? "
        user_name = gets.chomp
        sleep 1
        print "\nWelcome, #{user_name.capitalize}!"
        3.times do
            sleep 0.5
            print "."
        end
        print "to"
        3.times do
            sleep 0.3
            print "."
        end
        sleep 0.3
        print "the"
        5.times do
            sleep 0.3
            print "."
        end 
        13.times do 
            sleep 0.04
            print "."
        end
        4.times {puts "\n"}
        puts "********* " + "Hiking Trail CLI Application".colorize(:light_yellow) + " *********"
        puts "\nWith this application, you will be able to locate\n hiking trails anywhere in the United States.".colorize(:cyan)
        puts "\n************************************************"
        2.times {puts "\n"}
        sleep 1
    end

    def prompt_and_display_trails
        puts "\nPlease enter the five digit zip code of where you would like to hike."
        sleep 1
        zip_code = gets.chomp
        if zip_code.match(/^\d{5}$/)
            results = Geocoder.search(zip_code)
            lat = results[0].data["lat"]
            long = results[0].data["lon"]
            city = results[0].data["address"]["city"]
            state = results[0].data["address"]["state"]
            if city != nil || state != nil
                puts "\nYou entered zip code '" + "#{zip_code}".colorize(:cyan) + "' located in #{city}, #{state}."
                sleep 1
                puts "\nHow many miles from this location would you like to search for trails?\n(Enter a number between 1 and 100):"
                dist = gets.chomp
                sleep 1
                puts "\nYou entered '" + "#{dist}".colorize(:cyan) + "' miles."
                puts "\n"
                sleep 1
                puts "Here are the trails available within " + "#{dist} miles".colorize(:cyan) + " of" + " #{city}, #{state} #{zip_code}".colorize(:cyan) + ":"
                puts "\n"
                sleep 1
                self.get_trails_from_lat_long(lat, long, dist)
                puts "\n"
            else 
                puts "\nThere is no record for zip code '#{zip_code}'."
                self.prompt_and_display_trails
            end 
        else 
            puts "\nYou entered '#{zip_code}' which is an invalid zip code."
            self.prompt_and_display_trails 
        end 
    end


    def get_trails_from_lat_long(lat, long, dist)
        trails_array = TrailImporter.get_trails_by_lat_long(lat, long, dist)
        Trail.create_from_collection(trails_array)
        self.list_trails
    end

    def get_trail_details
        puts "\nTo get more details about a specific trail, please enter the " + "number".colorize(:light_yellow) + " corresponding to that trail:"
        trail_num = gets.chomp.to_i
        if (1..Trail.all.length).include?(trail_num)
            sorted_trails = Trail.all.sort {|a,b| a.length <=> b.length}
            puts "\nYou requested more details for" + " #{sorted_trails[trail_num - 1].name.upcase}".colorize(:cyan) + "..."
            sleep 1
            detail_hash = TrailDetailImporter.get_trail_details(sorted_trails[trail_num - 1].url)
            trail_detail = TrailDetails.new(detail_hash)
            self.list_trail_details(trail_detail)
        end 
    end 

    def list_trails
        sorted_trails = Trail.all.sort {|a,b| a.length <=> b.length}
        sorted_trails.each_with_index do |trail, index|
            puts "#{index + 1}. ".colorize(:light_yellow) + "#{trail.name.upcase}".colorize(:cyan) + " -" + " Length: #{trail.length} mi".colorize(:cyan) + " - #{trail.summary}\n"
        end
    end 

    def list_trail_details(trail_detail)
        specific_trail = TrailDetails.all.detect {|trail| trail == trail_detail}
        2.times {puts "\n"}
        puts "**********************************************"
        puts "\nTrail Details for ".colorize(:light_yellow) + "#{specific_trail.name.upcase}".colorize(:cyan)
        puts "\nLength: ".colorize(:cyan) + "#{specific_trail.length} miles"
        puts "Level of Difficulty: ".colorize(:cyan) + "#{specific_trail.difficulty}"
        puts "Dogs Allowed?: ".colorize(:cyan) + "#{specific_trail.dogs}"
        puts "Route Type:".colorize(:cyan) + "#{specific_trail.route}"
        puts "Highest Elevation: ".colorize(:cyan) + "#{specific_trail.high_elev}"
        puts "Lowest Elevation: ".colorize(:cyan) + "#{specific_trail.low_elev}"
        puts "Elevation Gain: ".colorize(:cyan) + "#{specific_trail.elev_gain}"
        puts "\nDescription: ".colorize(:cyan) + "#{specific_trail.description}\n"
    end 

end 