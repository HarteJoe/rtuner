# @author: Josef Harte
# RTuner is a simple program for tuning up a musical instrument

require 'gtk2'
require 'rubygame'

# Create & configure main window
window = Gtk::Window.new("RTuner")
window.border_width = 20
window.set_default_size( 400, 200 )
window.signal_connect('destroy') { Gtk.main_quit }

# Create & configure notes table & add buttons
$notesTable = Gtk::Table.new( 2, 6, true )
$notesTable.row_spacings = 10
$notesTable.column_spacings = 10
$notesTable.attach( Gtk::ToggleButton.new("A"), 0, 1, 0, 1 )
$notesTable.attach( Gtk::ToggleButton.new("A#"), 1, 2, 0, 1 )
$notesTable.attach( Gtk::ToggleButton.new("B"), 2, 3, 0, 1 )
$notesTable.attach( Gtk::ToggleButton.new("C"), 3, 4, 0, 1 )
$notesTable.attach( Gtk::ToggleButton.new("C#"), 4, 5, 0, 1 )
$notesTable.attach( Gtk::ToggleButton.new("D"), 5, 6, 0, 1 )
$notesTable.attach( Gtk::ToggleButton.new("D#"), 0, 1, 1, 2 )
$notesTable.attach( Gtk::ToggleButton.new("E"), 1, 2, 1, 2 )
$notesTable.attach( Gtk::ToggleButton.new("F"), 2, 3, 1, 2 )
$notesTable.attach( Gtk::ToggleButton.new("F#"), 3, 4, 1, 2 )
$notesTable.attach( Gtk::ToggleButton.new("G"), 4, 5, 1, 2 )
$notesTable.attach( Gtk::ToggleButton.new("G#"), 5, 6, 1, 2 )

# Create tool bar
toolbar = Gtk::Toolbar.new
toolbar.toolbar_style = Gtk::Toolbar::Style::BOTH
about = Gtk::ToolButton.new( Gtk::Stock::ABOUT )
quit = Gtk::ToolButton.new( Gtk::Stock::QUIT )
toolbar.insert( 0, about )
toolbar.insert( 1, quit )

# Create "About" dialog and attach to "About" button
about.signal_connect("clicked") do
	dialog = Gtk::AboutDialog.new
	dialog.set_program_name("RTuner")
	dialog.logo = Gdk::Pixbuf.new("resources/ruby.gif")
	dialog.authors = ["Josef Harte"]
	dialog.version = "1.0"
	dialog.comments= "RTuner is written in Ruby. It uses the GTK2 and Rubygame gems."
	dialog.run
	dialog.destroy
end

# Exit program when click "Quit"
quit.signal_connect("clicked") { Gtk.main_quit }

# Layout table for the 2 widgets - notes table & toolbar
layoutTable = Gtk::Table.new( 2, 1, false )
layoutTable.attach( toolbar, 0, 1, 0, 1 )
layoutTable.attach( $notesTable, 0, 1, 1, 2 )

# Untoggle all buttons except one that's pressed
def untoggleAll( clickedButton )
	$notesTable.each do |button|
		if !( button.equal?( clickedButton) ) then
			if button.active? == true then button.set_active(false) end
		end
	end
end

# A class to represent the audio files for each note
class AudioFile
	def initialize( note )
		@note = note
		if @note.include?("#") then 
			@note.chop!
			@note << "sharp"
		end
		@note.downcase!
		@note << ".mp3"
		
		@audio = Rubygame::Music.load( "resources/" + @note )
	end
		
	def play
		@audio.play( :repeats => -1 ) # Keep looping
	end
		
	def stop
		@audio.stop
	end
end

# Play sound on button click
notes = Hash.new
$notesTable.each do |togButton|
	notes[ togButton.label ] = AudioFile.new( togButton.label )
	togButton.signal_connect("toggled") do |button|
		if button.active? then
			untoggleAll( button )
			notes[ button.label ].play
		else
			notes[ button.label ].stop
		end
	end
end

# Set up main window and run
window.add( layoutTable )
window.show_all
Gtk.main

