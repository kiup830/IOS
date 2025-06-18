//
//  HistoryController.swift
//  PocketLLM
//
//  Created by 문재현 on 2025/06/15.
//

import Foundation
import UIKit

class HistoryController: UIViewController {
    
    @IBOutlet weak var historyScrollView: UIScrollView!
    @IBOutlet weak var historyStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        CoreDataManager.shared.deleteAllConversations()
        historyStack.translatesAutoresizingMaskIntoConstraints = false
        historyStack.widthAnchor.constraint(equalTo: historyScrollView.widthAnchor).isActive = true
        loadConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 기존 대화 목록 초기화
        for view in historyStack.arrangedSubviews {
            historyStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // 새로 대화 로드
        loadConversations()
    }

    func loadConversations() {
        let context = CoreDataManager.shared.viewContext
        let request = Conversation.fetchRequest()

        do {
            let conversations = try context.fetch(request).sorted{ ($0.createdAt ?? Date()) > ($1.createdAt ?? Date())
            }
                                                                
            for conv in conversations {
                let title = conv.title ?? "제목 없음"
                let button = UIButton(type: .system)
                button.setTitle("💬 \(title)", for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                button.contentHorizontalAlignment = .left
                button.backgroundColor = .secondarySystemBackground
                button.layer.cornerRadius = 8
                button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
                
                button.heightAnchor.constraint(equalToConstant: 60).isActive = true

                button.addAction(UIAction(handler: { _ in
                    self.openConversation(conv)
                }), for: .touchUpInside)

                historyStack.addArrangedSubview(button)
            }
        } catch {
            print("❌ 대화 불러오기 실패: \(error)")
        }
    }

    func openConversation(_ conversation: Conversation) {
        
        // MessageViewController에 대화내역 전달
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController {
            vc.currentConversation = conversation
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
