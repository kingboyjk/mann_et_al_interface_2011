function site = read_data_site(directory)
  %This cycles over all subdirectories, assumign each is a seperate bird
  %and uses the bird file reader to process
  r = pwd;
  cd(directory)
  
  d = dir;
  d = d(3:end);
  
  for i = 1:length(d)
    if d(i).isdir
    d(i).name
    bird = read_data_bird(d(i).name);
    site.bird(i) = bird;
    end
  end
  
  cd(r);