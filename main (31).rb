require 'json'

class Item
  attr_accessor :name, :weight

  def initialize(name, weight)
    @name = name
    @weight = weight
  end

  def to_h
    { name: name, weight: weight }
  end

  def to_s
    "#{name} (#{weight} גרם)"
  end
end

class Bag
  attr_accessor :items, :max_items, :mandatory_items

  def initialize(items = [], max_items = 6)
    @items = items
    @max_items = max_items
    @mandatory_items = ["עט", "מחברת", "ספר"]
  end

  def add_item(item)
    if @items.size >= max_items
      puts "❌ אי אפשר להוסיף את #{item.name} — התיק מלא (#{max_items} פריטים)"
    else
      @items << item
      puts "✔️ #{item.name} נוסף לתיק"
    end
  end

  def remove_item(item)
    @items.delete(item)
  end

  def has_item?(name)
    @items.any? { |i| i.name.downcase.include?(name.downcase) }
  end

  def current_weight
    @items.map(&:weight).sum
  end

  def check_mandatory_items
    missing = @mandatory_items.reject { |name| has_item?(name) }
    if missing.empty?
      puts "✅ כל פריטי החובה נמצאים בתיק"
    else
      puts "⚠️ חסרים פריטים: #{missing.join(', ')}"
    end
  end

  def status_summary
    total = @items.size
    mandatory_present = @mandatory_items.count { |name| has_item?(name) }
    mandatory_total = @mandatory_items.size

    status = "📦 #{total}/#{max_items} פריטים נארזו\n"
    status += "📋 #{mandatory_present}/#{mandatory_total} פריטי חובה נמצאים\n"

    status += if mandatory_present == mandatory_total
                "✅ כל החובה קיימים!"
              elsif mandatory_present.zero?
                "❌ שום פריט חובה לא נארז!"
              else
                "⚠️ שים לב שחסרים פריטי חובה"
              end

    status
  end

  def to_h
    {
      items: @items.map(&:to_h),
      total_weight: current_weight,
      missing_mandatory: @mandatory_items.reject { |name| has_item?(name) },
      status_summary: status_summary
    }
  end
end

class Student
  attr_accessor :name, :bag

  def initialize(name)
    @name = name
    @bag = Bag.new
  end

  def pack(item)
    @bag.add_item(item)
  end

  def unpack(item)
    @bag.remove_item(item)
  end

  def show_bag
    puts "#{name} נושא בתיק: #{@bag.items.map(&:to_s).join(', ')}"
    puts "משקל כולל: #{@bag.current_weight} גרם"
    puts @bag.status_summary
  end

  def export_to_json
    data = {
      student: name,
      bag: @bag.to_h
    }

    File.open("bag_data.json", "w:utf-8") { |f| f.write(JSON.pretty_generate(data)) }

    system("start bag_data.json") if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
    system("open bag_data.json") if RUBY_PLATFORM.include?("darwin")
    system("xdg-open bag_data.json") if RUBY_PLATFORM.include?("linux")

    puts "📂 הקובץ נוצר ונפתח: bag_data.json"
  end
end

# ✨ שימוש:
student = Student.new("תמר")
student.pack(Item.new("עט", 20))
student.pack(Item.new("מחברת", 200))
student.pack(Item.new("ספר היסטוריה", 900))
student.pack(Item.new("מחדד", 30))
student.pack(Item.new("עפרון", 25))
student.pack(Item.new("קלמר", 400))
student.pack(Item.new("חטיף", 150)) # חורג מהמגבלה

student.show_bag
student.export_to_json