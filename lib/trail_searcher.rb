
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
            puts "\nEnter '1' to go back to your list of trails."
            puts "Enter '2' to enter a new zip code."
            puts "Enter 'exit' to close this application."
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
        5.times {puts "\n"}
        puts "******** Hiking Trail CLI Application ********"
        puts "\nWith this application, you will be able to\nlocate hiking trails anywhere in the United States."
        puts "\n**********************************************"
        2.times {puts "\n"}
        sleep 1
    end

    def prompt_and_display_trails
        puts "\nPlease enter the five digit zip code of where you would like to hike."
        sleep 1
        zip_code = gets.chomp
        results = Geocoder.search(zip_code)
        lat = results[0].data["lat"]
        long = results[0].data["lon"]
        puts "\nYou entered zip code: #{zip_code}."
        sleep 1
        puts "\nHow many miles would you like to extend your search?\n(Enter a number between 1 and 100):"
        dist = gets.chomp
        sleep 1
        puts "\nYou entered #{dist} miles."
        puts "\n"
        sleep 1
        puts "Here are the hikes available to you in order of trail length:"
        puts "\n"
        sleep 1
        self.get_trails_from_lat_long(lat, long, dist)
        puts "\n"
    end


    def get_trails_from_lat_long(lat, long, dist)
        trails_array = TrailImporter.get_trails_by_lat_long(lat, long, dist)
        Trail.create_from_collection(trails_array)
        self.list_trails
    end

    def get_trail_details
        puts "\nTo get more details about a specific trail, please enter the number corresponding to that trail:"
        trail_num = gets.chomp.to_i
        if (1..Trail.all.length).include?(trail_num)
            sorted_trails = Trail.all.sort {|a,b| a.length <=> b.length}
            puts "\nYou requested more details for #{sorted_trails[trail_num - 1].name.upcase}..."
            sleep 1
            detail_hash = TrailDetailImporter.get_trail_details(sorted_trails[trail_num - 1].url)
            trail_detail = TrailDetails.new(detail_hash)
            self.list_trail_details(trail_detail)
        end 
    end 

    def list_trails
        sorted_trails = Trail.all.sort {|a,b| a.length <=> b.length}
        sorted_trails.each_with_index do |trail, index|
            puts "#{index + 1}. #{trail.name.upcase} - Length: #{trail.length} mi - #{trail.summary}\n"
        end
    end 

    def list_trail_details(trail_detail)
        specific_trail = TrailDetails.all.detect {|trail| trail == trail_detail}
        2.times {puts "\n"}
        puts "**********************************************"
        puts "\nTrail Details for #{specific_trail.name.upcase}"
        puts "\nLength: #{specific_trail.length} miles"
        puts "Level of Difficulty: #{specific_trail.difficulty}"
        puts "Dogs Allowed?: #{specific_trail.dogs}"
        puts "Route Type: #{specific_trail.route}"
        puts "Highest Elevation: #{specific_trail.high_elev}"
        puts "Lowest Elevation: #{specific_trail.low_elev}"
        puts "Elevation Gain: #{specific_trail.elev_gain}"
        puts "\nDescription: #{specific_trail.description}\n"
    end 

end 