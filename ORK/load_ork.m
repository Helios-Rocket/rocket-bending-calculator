function rocket = load_ork(filename)
zip_out = 'temp';

unzip(filename, zip_out);
ork_name = fullfile(zip_out, 'rocket.ork');

ork = readstruct(ork_name, 'FileType','xml');

rocket = ork.rocket;
rmdir('temp', 's');
end