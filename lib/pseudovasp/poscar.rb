class Poscar 
  attr_accessor :head, :whole_scale, :lat_vec, :pos_size, :pos, :elements, :relax
  RE_3F=/([-+]?[\d\.]+)\s*([-+]?[\d\.]+)\s*([-+]?[\d\.]+)/
  RE_3F3D=/([-+]?[\d\.]+)\s*([-+]?[\d\.]+)\s*([-+]?[\d\.]+)\s*(\d)\s*(\d)\s*(\d)/
  RE_3F3W=/([-+]?[\d\.]+)\s*([-+]?[\d\.]+)\s*([-+]?[\d\.]+)\s*(\w)\s*(\w)\s*(\w)/

  def initialize(file_name)
    file = open(file_name)
    @head = file.gets.chomp
    @whole_scale = file.gets.chomp.to_f

    @lat_vec = []
    3.times { @lat_vec << file.gets.match(RE_3F)[1..3].map{|item| item.to_f} }
    sizes = file.gets.chomp.split(" ").map{|item| item.to_i}
    print "Failed in reading POSCAR.\n" if !(file.gets =~ /Direct/) 
    @pos=[]
    @pos_size=0
    @elements=[]
    @relax=[]
    sizes.each_with_index{|size,element|
      size.times{ 
        tmp= file.gets.match(RE_3F3D)[1..6]
#        tmp= file.gets.match(RE_3F3W)[1..6]
        @pos << [tmp[0],tmp[1],tmp[2]].map{|it| it.to_f}
        @relax << [tmp[3],tmp[4],tmp[5]].map{|it| it.to_i}
#        @relax << [tmp[3],tmp[4],tmp[5]].map{|it| 
#          if it=='T' then 1 else 0 end
#        }
        @elements << element
      }
    }
    @pos_size = @pos.size
    file.close
  end

  def display # poscar format
    text=""
    text << sprintf("%s\n",@head)
    text << sprintf("%f\n",@whole_scale)
    @lat_vec.each {|vec| text << sprintf("%f %f %f\n",vec[0],vec[1],vec[2])}
    text << sprintf("%d\n",@pos_size)
    text << sprintf("Direct\n")
    @pos.each{|pos| text << sprintf("%f %f %f\n",pos[0],pos[1],pos[2])}
    return text
  end

  def display2 #real POSCAR for Al 2times 
    text=""
    text << sprintf("%s\n",@head)
    text << sprintf("%f\n",@whole_scale)
    al=8.0827999115
    @lat_vec.each {|vec| 
      text << sprintf("%f %f %f\n",al*2.0*vec[0],al*vec[1],al*vec[2])
    }
    text << sprintf("%d\n",@pos_size)
    text << sprintf("Direct\n")
    @pos.each{|pos| text << sprintf("%f %f %f\n",(1.0+pos[0])/2.0,pos[1],pos[2])}
    return text
  end

  def to_processing
    text=""
    text << sprintf("%s\n",@head)
    text << sprintf("%f\n",@whole_scale)
    @lat_vec.each {|vec| text << sprintf("%f,%f,%f\n",vec[0],vec[1],vec[2])}
    text << sprintf("%d\n",@pos_size)
    text << sprintf("Direct\n")
    @pos.each{|pos| text << sprintf("%f,%f,%f\n",pos[0],pos[1],pos[2])}
    return text
  end

  def to_processing2  #shift for periodicity
    text=""
    text << sprintf("%s\n",@head)
    al=1.0
    @lat_vec.each {|vec| 
      text << sprintf("%f,%f,%f\n",al*2.0*vec[0],al*vec[1],al*vec[2])
    }
    text << sprintf("%f\n",@whole_scale)
    text << sprintf("%d\n",@pos_size)
    text << sprintf("Direct\n")
    @pos.each{|pos| text << sprintf("%f,%f,%f\n",(1.0+pos[0])/2.0,pos[1],pos[2])}
    return text
  end
end

