class Character < ActiveRecord::Base
  attr_writer :current_step
    has_many :stats, :dependent => :destroy
    validates :name, 
              :presence => { :message => "A voice in your head tells you to choose a name...any name! Ideally with letters and everything."},
              format: { with: /\A[a-zA-Z\d ]*\Z/, :message => "You get a strong feeling that your name is made up almost entirely out of letters, and maybe spaces. Numbers probably indicate you have brain damage and/or bad parents, but that's not your fault." },
              :if => lambda { |f| f.current_step == "name" }
    validates :avatar_image_path,
              :presence => { :message =>  "Your vision is blurry and your hand-eye coordination is terrible, but you know you can do this. At least...you hope you can." },
              :if => lambda { |f| f.current_step == "avatar"}
    validates_presence_of :gender, :if => lambda { |f| f.current_step == "gender"}, :message => "Clearly deeply confused on the issue of your own gender and carrot-hood, but you somehow feel sure that if you just pick something, you can change your mind later and nobody will ever know."

  def build_initial_character_stats
    character_location = Quality.find_by_name("Location")
    stats.create(quality_id: character_location.id, points: "1")
  end

  def get_stat(quality_name)
    quality = Quality.find_by_name(quality_name)
    stat = Stat.find_by(:quality_id => quality.id, :character_id => self.id)
  end 
  
  # Following is the logic for the Intro Form Wizard 
  def current_step
    @current_step || steps.first
  end

  def steps
    %w[intro name gender avatar final]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end  

end
