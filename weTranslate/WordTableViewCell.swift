//
//  TranslationTableViewCell.swift
//  weTranslate
//
//  Created by Lionel on 2/15/16.
//  Copyright © 2016 weTranslate. All rights reserved.
//

import UIKit

final class WordTableViewCell: UITableViewCell {

    // MARK: - Properties

    var viewModel: WordViewModel? {
        didSet {
            if let viewModel = viewModel {
                wordLabel.text = viewModel.word.capitalizedString
                senseLabel.text = "(\(viewModel.sense))"
            }
        }
    }

    private let wordLabel: Label = {
        let label = Label(textColor: UIColor(red: 247/255, green: 80/255, blue: 50/255, alpha: 1), font: UIFont(name: "HelveticaNeue", size: 15.0))
        label.numberOfLines = 0
        label.textColor = Color.brand
        label.font = Font.font()
        return label
    }()

    private let senseLabel: Label = {
        let label = Label(textColor: UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1), font: UIFont(name: "HelveticaNeue", size: 12.0))
        label.numberOfLines = 0
        label.textColor = Color.standardText
        label.font = Font.font(style: .Caption1)
        return label
    }()

    private let columnView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .Top
        stackView.spacing = 10
        return stackView
    }()

    private let bodyView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Vertical
        stackView.spacing = 5
        return stackView
    }()


    // MARK: - Init

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.opaque = true
        backgroundColor = .whiteColor()
        opaque = true

        bodyView.addArrangedSubview(wordLabel)
        bodyView.addArrangedSubview(senseLabel)
        columnView.addArrangedSubview(bodyView)
        contentView.addSubview(columnView)

        let margins = contentView.layoutMarginsGuide
        columnView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
        columnView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
        columnView.topAnchor.constraintEqualToAnchor(margins.topAnchor).active = true
        columnView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor).active = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
