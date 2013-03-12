function bird = read_data_bird(directory)
  %This works on Chris's data specifically and transfers it to a particular set of co-ords, but can easily be adapted to
  %circumstance
  r = pwd;
  cd(directory)
  
  d = dir;
  d = d(3:end); %exclude . and ..
  
  c = 0;
  for i = 1:length(d)
    %if d(i).name(1) == 'F' %Chnage this to determine which files are used
      c = c+1;
      filename = d(i).name
      [x, t] = read_standard_data(filename);
      x = fill_missing_data(x, t);
      %x = conv_coord_40k(x);
      
      bird.path{c} = x;
      
    %end
  end
  
  bird.name = directory;
  cd(r)
  
  

  
  