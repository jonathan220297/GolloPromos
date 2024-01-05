//
//  CheckboxWithTitle.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 12/8/23.
//

import UIKit
import SnapKit

class CheckboxWithTitle: UIView {
    
    var isChecked = false
    let checkbox = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init (text: String) {
        super.init(frame: .zero)
        createSubViews(text: text)
    }
    
    init (attributedTex: NSAttributedString) {
        super.init(frame: .zero)
        createSubViews(attributedText: attributedTex)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func createSubViews(text: String) {
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = text
        label.textAlignment = .left
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
        }
        
        checkbox.image = UIImage(systemName: "square")
        checkbox.contentMode = .scaleAspectFit
        checkbox.tintColor = UIColor(named: "Black")
        
        addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
        }
    }
    
    private func createSubViews(attributedText: NSAttributedString) {
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = attributedText
        label.textAlignment = .left
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
        }
        
        checkbox.image = UIImage(systemName: "square")
        checkbox.contentMode = .scaleAspectFit
        checkbox.tintColor = UIColor(named: "Black")
        
        addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
        }
    }
    
    public func toggle() {
        self.isChecked = !isChecked
        
        if !isChecked {
            checkbox.image = UIImage(systemName: "checkmark.square.fill")
        } else {
            checkbox.image = UIImage(systemName: "square")
        }
    }
}
