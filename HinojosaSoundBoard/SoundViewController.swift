//
//  SoundViewController.swift
//  HinojosaSoundBoard
//
//  Created by Mac 04 on 24/05/23.
//

import UIKit
import AVFoundation


class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var recordingStartTime: Date?
    var timer: Timer?
    var recordingDuration:String = ""


    @IBOutlet weak var volumenCambiado: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        volumenCambiado.addTarget(self, action: #selector(volumenCambiados(_:)), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func volumenCambiados(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value
    }


    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
           grabarAudio?.stop()
          stopRecording()
            
           grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
           grabarAudio?.record()
            startRecording()

           grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }

    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
           try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio?.volume = volumenCambiado.value
           reproducirAudio!.play()
           print("Reproduciendo")
        }catch{}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf:audioURL!)! as Data
        grabacion.duracion = durationLabel.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    func startRecording() {
        // Tu código para comenzar la grabación
        
        // Establecer el tiempo de inicio de la grabación
        recordingStartTime = Date()
        
        // Configurar el temporizador para actualizar el UILabel
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateDurationLabel), userInfo: nil, repeats: true)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int((duration / 60).truncatingRemainder(dividingBy: 60))
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))

        let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
        return formattedDuration
    }

    
    @objc func updateDurationLabel() {
        guard let startTime = recordingStartTime else {
            return
        }
        
        let currentTime = Date()
        let duration = currentTime.timeIntervalSince(startTime)
        
        // Formatear la duración en el formato deseado (por ejemplo, HH:mm:ss)
        let durationText = formatDuration(duration)
        recordingDuration = durationText
        
        // Actualizar el UILabel con la duración
        durationLabel.text = durationText
    }
    func stopRecording() {
        // Tu código para detener la grabación
        
        // Detener el temporizador
        timer?.invalidate()
        timer = nil
    }
    
    func configurarGrabacion(){
       do{
           let session = AVAudioSession.sharedInstance()
           try session.setCategory(AVAudioSession.Category.playAndRecord, mode:AVAudioSession.Mode.default, options: [])
           try session.overrideOutputAudioPort(.speaker)
           try session.setActive(true)


           let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).first!
           let pathComponents = [basePath,"audio.m4a"]
           audioURL = NSURL.fileURL(withPathComponents: pathComponents)!


           print("*****************")
           print(audioURL!)
           print("*****************")


           var settings:[String:AnyObject] = [:]
           settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
           settings[AVSampleRateKey] = 44100.0 as AnyObject?
           settings[AVNumberOfChannelsKey] = 2 as AnyObject?


           grabarAudio = try AVAudioRecorder(url:audioURL!, settings: settings)
           grabarAudio!.prepareToRecord()
       }catch let error as NSError{
           print(error)
       }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
