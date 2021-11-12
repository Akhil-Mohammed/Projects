
//Akhil Mohammed, Yara Hanafi
package lib.view;

import java.io.*;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Optional;

import javafx.scene.media.Media;
import javafx.scene.media.MediaPlayer;
import java.io.File;



import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.text.Text;
import javafx.stage.Stage;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.google.gson.stream.JsonReader; 

public class songcontroller {
	
	@FXML ListView<song> songlist;
	
	@FXML TextField add_songname;
	@FXML TextField add_artist;
	@FXML TextField add_album;
	@FXML TextField add_year;
	
	@FXML TextField edit_songname;
	@FXML TextField edit_artist;
	@FXML TextField edit_album;
	@FXML TextField edit_year;
	
	@FXML Text songname;
	@FXML Text artist;
	@FXML Text album;
	@FXML Text year;
	
	@FXML Button add_button;
	@FXML Button edit_button;
	@FXML Button delete_button;
	
	private ArrayList<song> Songs = new ArrayList<song>();
	private ObservableList<song> obsList;   


	public void start(Stage mainstage) throws FileNotFoundException {
		//read file into project
		Gson gson = new Gson();
		JsonReader reader = new JsonReader(new FileReader("Songs.json"));
		
		ArrayList<song> x = gson.fromJson(reader, new TypeToken<ArrayList<song>>() {
        }.getType());
		
		if(x!= null) {
			Songs = x;
		}
         
		//updating list
		updatelist(0);
		
		//listener
        songlist.getSelectionModel().selectedIndexProperty().addListener(
        		(obs,oldVal, newVal) -> 
				    details());
		
       //writing to file 
	Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {	
	public void run() {
		if(Songs != null) {
		try {
			Gson gson = new Gson();
		    Writer writer = new FileWriter("Songs.json",false);
		    String json = gson.toJson(obsList);
		    writer.write(json);
		    writer.close();

		} catch (Exception ex) {
		    ex.printStackTrace();
		}
	}
	}
	}));
}

	
	
	public void details() { //to show the selected song details
		song item = songlist.getSelectionModel().getSelectedItem();
		if (item != null) {
		songname.setText(item.songname);
		artist.setText(item.artist);
		album.setText(item.album);
		year.setText(item.year);
		
		}
		
	}
	
	//Notes --> this method is to be used to update the current list and deciding which index to be pre-selected
	public void updatelist(int indextoselect) {
		obsList = FXCollections.observableArrayList(Songs);
		songlist.setItems(obsList); 
		songlist.getSelectionModel().select(indextoselect);
		details();
		
	}
	
	public boolean hasVerticalBar(String s) {
		
		if(s.contains("|")) {
			return true;
		}
		
		return false;
	}
	
	
	//Notes --> Save any null value as a string that is ""
	//Use the updatelist method to update list after any changes to ArrayList Songs
	
	public void add(ActionEvent e) {  
		
		Alert confirm  = new Alert(AlertType.CONFIRMATION);
		confirm.setTitle("Confirmation Message");
		confirm.setHeaderText("Select OK to confirm changes");
		Optional<ButtonType> result = confirm.showAndWait();
		
		if(result.isPresent() && result.get() == ButtonType.OK)
		{
			Alert alert = new Alert(AlertType.ERROR);
			
			if (hasVerticalBar(add_songname.getText()) || hasVerticalBar(add_artist.getText())) {
				alert.setTitle("Add Song Error Message");
		        alert.setHeaderText("Error");
		        alert.setContentText("Cannot use special character |");
		        alert.showAndWait();
		        
		        return;
			}
			else if(add_songname.getText() == null || add_songname.getText().trim() == "" 
					|| add_artist.getText() == null || add_artist.getText().trim() == "" )
			{
		       
		        alert.setTitle("Add Song Error Message");
		        alert.setHeaderText("Error");
		        alert.setContentText("Enter a song name and artist");
		        alert.showAndWait();
		        
		        return;
		    }
			
			
			else if(add_year.getText().trim() != "" && Integer.parseInt(add_year.getText().trim()) < 1)
			{
				 	alert.setTitle("Add Year Error Message");
			        alert.setHeaderText("Error");
			        alert.setContentText("Enter a valid year. Year must be an integer greater than 0");
			        alert.showAndWait();
			}
			else
			{
				for(song song : obsList) {
					if(song.songname.toLowerCase().trim().equals(add_songname.getText().toLowerCase().trim()) && 
							song.artist.toLowerCase().trim().equals(add_artist.getText().toLowerCase().trim())) {
						
						alert.setTitle("Add Song Error Message");
				        alert.setHeaderText("Error");
				        
			            alert.setContentText("Song is already in the album. Enter a new song that's"
			            		+ " not already contained in the list");
				        alert.showAndWait();
					
				        return;
					 }
				}
				
				song addedSong = new song(add_songname.getText().trim(), add_artist.getText().trim(), add_album.getText().trim(), 
						add_year.getText().trim());

				obsList.add(addedSong);
				
				sortAlphabetically(obsList);
				songlist.getSelectionModel().select(addedSong);
				details();
			}
		}		
	}

	
	
	public void edit(ActionEvent r) { 
		Alert confirm = new Alert(AlertType.CONFIRMATION);
		confirm.setTitle("Confirmation Message");
		confirm.setHeaderText("Select OK to confirm changes");
		Optional<ButtonType> result = confirm.showAndWait();
		
		if(result.isPresent() && result.get() == ButtonType.OK)
		{
			if (hasVerticalBar(edit_songname.getText()) || hasVerticalBar(edit_artist.getText())) {
				Alert alert = new Alert(AlertType.ERROR);
				alert.setTitle("Edit Song Error Message");
		        alert.setHeaderText("Error");
		        alert.setContentText("Cannot use special character |");
		        alert.showAndWait();
		        
		        return;
			}
			else
			{
				for(song song : obsList)
				{
					System.out.println(song.songname + " " + song.artist);
					
					if(song.songname.toLowerCase().trim().equals(edit_songname.getText().toLowerCase().trim()) && 
							song.artist.toLowerCase().trim().equals(edit_artist.getText().toLowerCase().trim())) {
						 
			//
						Alert alert = new Alert(AlertType.ERROR);
						alert.setTitle("Edit Song Error Message");
				        alert.setHeaderText("Error");
				        alert.setContentText("");
				        alert.showAndWait();
					
				        return;
					}
				}
				
				int removeSongIndex = songlist.getSelectionModel().getSelectedIndex();
						
				obsList.remove(removeSongIndex);
				
				song updateSong = new song(edit_songname.getText().trim(), edit_artist.getText().trim(), edit_album.getText().trim(), 
						edit_year.getText().trim());

				obsList.add(updateSong);
				sortAlphabetically(obsList);
				songlist.getSelectionModel().select(updateSong);
				details();
			}
			}
	}

	public void delete(ActionEvent c) {  
		
		Alert confirm = new Alert(AlertType.CONFIRMATION);
		confirm.setTitle("Confirmation");
		confirm.setHeaderText("Select OK to confirm changes");
		Optional<ButtonType> result = confirm.showAndWait();
		
		if(result.isPresent() && result.get() == ButtonType.OK)
		{
			int removeSongIndex = songlist.getSelectionModel().getSelectedIndex();
			
			obsList.remove(removeSongIndex);
			int newIndex;
			
			if(obsList.isEmpty()) {
				
				songname.setText("");
				artist.setText("");
				album.setText("");
				year.setText("");
				return;
			}
			else if(obsList.size() < removeSongIndex + 1) {
				newIndex = removeSongIndex -1;
			}
			else {
				newIndex = removeSongIndex;
			}
			
			songlist.getSelectionModel().select(newIndex);
			details();
		}
	}
	
	public void sortAlphabetically (ObservableList<song> list)
	{
		Comparator<song> cmpare = Comparator.comparing(song::getNameLower); 
		FXCollections.sort(list, cmpare);		
	}
}