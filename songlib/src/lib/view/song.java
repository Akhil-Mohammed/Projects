//Akhil Mohammed, Yara Hanafi
package lib.view;

public class song {
	String songname;
	String artist;
	String album;
	String year;
	
	public song(String songname, String artist, String album, String year){
		this.songname = songname;
		this.artist = artist;
		this.album = album;
		this.year = year;
	}
	
	
	public String getNameLower() {
		return songname.toLowerCase();
	}
	
	@Override
	public String toString() {
		return this.songname + " - " + this.artist;
	}
}
