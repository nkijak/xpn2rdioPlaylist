require 'nokogiri'
require 'open-uri'
require 'yaml'

@base = "http://xpn.org/music-artist/885-countdown/2013?page="
ACCESS_TOKEN_FILE = '.rdio_access_token_xpn'
CACHED_DATA_FILE = 'songlist.cache'


def load_all_the_things
    begin
       YAML.load(File.read(CACHED_DATA_FILE))
    rescue
       store_all_the_things
    end 
end

def store_all_the_things
    cache = File.new(CACHED_DATA_FILE, 'w')
    all_the_things = fetch_all_the_things
    cache.write(YAML.dump(all_the_things))
    all_the_things
end

def fetch_all_the_things
   (1..18).inject([]) do |acc,i|
        acc + fetch_songs_for_page(i)
    end
end

def fetch_songs_for_page(i) 
    url = @base + i.to_s
    doc = Nokogiri::HTML(open(url))
    doc.css('tr.countdown').collect do |tr|
        t = {:artist => tr.css('td:first+td').first.content, 
             :song => tr.css('td.song').first.content,
             :year => tr.css('td.song+td').first.content}
        puts t
        t
    end
end

def with_frequency(songs)
    songs.inject({}) do |counts, song|
        count = counts[song[:artist]] || 0
        counts[song[:artist]] = count + 1
        counts
    end
end

def with_weight(songs)
    total = songs.count
    counts = {}
    songs.each_with_index do |song, i|
        weight = (total - i)/(total * 1.0)
        count = counts[song[:artist]] || 0
        counts[song[:artist]] = count + weight
    end
    counts
end

def with_positional_score(songs)
    counts = {}
    songs.each_with_index do |song, i|
        count = counts[song[:artist]] || 0
        counts[song[:artist]] = count + (songs.length - i)
    end 
    counts
end

def max_positional_score(songs)
    songs.length * (songs.length + 1) / 2.0
end

def sorted_by_count(counts)
    counts.sort{|a,b| b[1] <=> a[1]}.each {|k,v| puts "#{k} => #{v}"}
end

def counts_to_objects(counts)
    counts.collect do |count|
        {:artist => count[0], :score => count[1]}
    end
end

def save_to(file, counts)
    File.new(file, 'w').write(YAML.dump(counts_to_objects(counts)))
end

def save_scv_to(file, counts)
    file = File.new(file, 'w')
    counts.each do |count|
        file.write("\""+count.join("\",\"")+"\"\n");
    end
    file.flush
    file.close
end

#TODO does ruby have a zip function? does it work on maps?
def dual_combine(a,b) 
    a.collect do |k,v|
        other = b[k]
        [k, v, other]
    end
end

def save_info
    songs = load_all_the_things
    save_to('with_frequency.yml', sorted_by_count(with_frequency(songs)))
    save_to('with_weight.yml', sorted_by_count(with_weight(songs)))
    save_scv_to('freq-weight.csv', dual_combine(with_frequency(songs), with_weight(songs)))
    save_scv_to('freq-sum_score.csv', dual_combine(with_frequency(songs), with_positional_score(songs)))
    puts "max score is #{max_positional_score(songs)}"
end