
//Akhil Mohammed, Yara Hanafi
package lib.App;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;
import lib.view.songcontroller;


public class SongLib extends Application {
	
	@Override
	public void start(Stage primaryStage) 
	throws Exception {
		// TODO Auto-generated method stub
		FXMLLoader loader = new FXMLLoader();
		loader.setLocation(getClass().getResource("/lib/view/design.fxml")); 
		VBox root = (VBox)loader.load();
		songcontroller listController = 
				loader.getController();
		listController.start(primaryStage);
		Scene scene = new Scene(root);
		primaryStage.setScene(scene);
		primaryStage.setTitle("Song Library");
		primaryStage.setResizable(false);
		primaryStage.show();
		
		
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		launch(args);

	}

}







