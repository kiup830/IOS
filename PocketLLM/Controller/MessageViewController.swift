//
//  MessageViewController.swift
//  PocketLLM
//
//  Created by 문재현 on 2025/06/14.
//


import UIKit

class MessageViewController: UIViewController {
    
    var currentConversation: Conversation?
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var messageStack: UIStackView!
    
    @IBOutlet weak var recordingButton: UIButton!
    
    @IBOutlet weak var recordingLabel: UILabel!
    
    var isRecording = false
    let mic_recodring = UIImage(named:"mic_recording")
    let mic_idle = UIImage(named:"mic_idle")
    
    var latestAudioFileURL: URL?
    
    
    // Services폴더의 AudioRecorderService.swift내 함수
    let recordService = AudioRecorderService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentConversation == nil {
            startNewConversation()
        } else {
            loadExistingConversation()
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.hidesBackButton = true
        
        CoreDataManager.shared.saveContext()
    }
    
    
    func loadExistingConversation() {
        guard let conversation = currentConversation,
              let messages = conversation.messages as? Set<MiniConversation> else {return}

        let sortedMessages = messages.sorted {
            guard let date0 = $0.timestamp, let date1 = $1.timestamp else { return false }
            return date0 < date1
        }

        for msg in sortedMessages {
            let userLabel = createMessageLabel(text: msg.userText ?? "내용 없음", isUser: true)
            let aiLabel = createMessageLabel(text: msg.aiText ?? "내용없음", isUser: false)
            messageStack.addArrangedSubview(userLabel)
            messageStack.addArrangedSubview(aiLabel)
        }
    }
    
    func startNewConversation() {
        let context = CoreDataManager.shared.viewContext

        let newConv = Conversation(context: context)
        newConv.id = UUID()
        newConv.createdAt = Date()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 a h:mm"
        
        let dateString = formatter.string(from: Date())
        newConv.title = "대화 \(dateString)"

        try? context.save()
        self.currentConversation = newConv
    }
    
    
    func saveAndDisplayMiniConversation(userText: String, aiText: String) {
        guard let conversation = currentConversation else { return }
        let context = CoreDataManager.shared.viewContext

        let mini = MiniConversation(context: context)
        mini.id = UUID()
        mini.userText = userText
        mini.aiText = aiText
        mini.timestamp = Date()
        mini.conversation = conversation

        try? context.save()

        // ✅ UIStackView에 추가
        let userLabel = createMessageLabel(text: userText, isUser: true)
        let aiLabel = createMessageLabel(text: aiText, isUser: false)

        messageStack.addArrangedSubview(userLabel)
        messageStack.addArrangedSubview(aiLabel)
    }
    
    func createMessageLabel(text: String, isUser: Bool) -> UILabel {
        let label = PaddingLabel()
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = isUser ? .right : .left
        label.textColor = .white
        label.backgroundColor = isUser ? .systemBlue : .darkGray
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }

    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        CoreDataManager.shared.saveContext()

        // 대화 저장 후이전 화면으로 되돌아가기
        navigationController?.popViewController(animated: true)
    }


    
    @IBAction func click_recording(_ sender: Any) {
        
        guard let button = sender as? UIButton else {return}
        
        isRecording.toggle()
        
        let imageName = isRecording ? "mic_recording" : "mic_idle"
        recordingLabel.text = isRecording ? "🔴 녹음 중..." : "음성을 입력하세요"
        
        if isRecording {
            BlinkEffect.start(on: recordingLabel)
            
            // recording function starts..
            latestAudioFileURL = recordService.startRecording()
            
            
            
        } else {
            BlinkEffect.stop(on: recordingLabel)
            
            // recording function stops..
            recordService.stopRecording()
            
            // 녹음된 오디오 경로를 입력하여 Text로 변환(OpenAI-Whisper)
            guard let audioURL = latestAudioFileURL else {
                        print("❌ 녹음 파일 URL 없음")
                        return
                    }

            print("녹음된 파일 경로: \(audioURL.path)")

            STTService.shared.transcribeAudio(at: audioURL) { text in
                DispatchQueue.main.async {
                    guard let inputText = text else {
                                        print("❌ STT 변환 실패")
                                        return
                                    }
                    
                    print("STT 텍스트: \(inputText)")
                    
                    LLMService.shared.runLLM(with: inputText) { response in
                
                        DispatchQueue.main.async {
                            
                            print(" GPT 응답: \(response)")
                            
                            // 이후 UIstackview에 응답 추가
                            self.saveAndDisplayMiniConversation(userText: inputText, aiText: response)
                        }
                        
                    }
                    
                }
            }
            
            
        }
        
        button.setImage(UIImage(named: imageName), for: .normal)
                
        
        
    }
    
    
    
}
 
