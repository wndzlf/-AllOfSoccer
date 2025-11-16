//
//  filterDetailView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/03.
//

import UIKit

protocol FilterDetailViewDelegate: AnyObject {
    func finishButtonDidSelected(_ detailView: FilterDetailView, selectedList: [String])
    func cancelButtonDidSelected(_ detailView: FilterDetailView, selectedList: [String])
}

class FilterDetailView: UIView {
    var didSelectedFilterList: [String: FilterType] = [:]
    var filterType: FilterType? {
        didSet {
            let finishButtonTitle = self.didSelectedFilterList.isEmpty ? "선택" : "필터적용하기 (데이터필요)"
            self.finishButton.setTitle(finishButtonTitle, for: .normal)
            self.tagCollectionView.reloadData()
            
            // CollectionView가 로드된 후 높이 업데이트
            DispatchQueue.main.async { [weak self] in
                self?.updateViewHeight()
            }
        }
    }
    weak var delegate: FilterDetailViewDelegate?
    private var tagCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    
    // 동적 높이 계산을 위한 프로퍼티
    private var contentViewHeightConstraint: NSLayoutConstraint?
    private var viewHeightConstraint: NSLayoutConstraint?
    private var finishButtonBottomConstraint: NSLayoutConstraint?

    private var finishButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "tagBackTouchUpColor")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("선택하기", for: .normal)
        return button
    }()

    private var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "장소"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private var cancelButton: UIButton = {
        let button = UIButton()
        let cancelImage = UIImage(systemName: "xmark")
        button.setImage(cancelImage, for: .normal)
        button.frame.size = CGSize(width: 22, height: 22)
        button.tintColor = UIColor(ciColor: .black)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }

    func loadView() {
        self.setupCollectionView()
        self.setupConstraint()

        self.finishButton.addTarget(self, action: #selector(finishButtonTouchUp), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)
    }

    private func setupCollectionView() {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowlayout.itemSize = CGSize(width: 107, height: 36)
        flowlayout.scrollDirection = .vertical
        self.tagCollectionView.collectionViewLayout = flowlayout

        self.tagCollectionView.delegate = self
        self.tagCollectionView.dataSource = self
        self.tagCollectionView.allowsMultipleSelection = true
        self.tagCollectionView.backgroundColor = .white
        self.tagCollectionView.isScrollEnabled = true // 스크롤 활성화
        self.tagCollectionView.showsVerticalScrollIndicator = true // 스크롤바 표시
        self.tagCollectionView.bounces = true // 바운스 효과 활성화

        self.tagCollectionView.register(FilterDetailTagCollectionViewCell.self, forCellWithReuseIdentifier: FilterDetailTagCollectionViewCell.reuseId)
    }

    private func setupConstraint() {
        // 초기 높이 설정 (최소 높이)
        let initialHeight: CGFloat = 244
        self.frame.size = CGSize(width: 375, height: initialHeight)

        self.debugBorder()


        self.addSubview(self.contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // contentView 높이 제약조건을 저장
        self.contentViewHeightConstraint = self.contentView.heightAnchor.constraint(equalToConstant: 182)
        
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            self.contentViewHeightConstraint!
        ])

        self.addSubview(self.finishButton)
        self.finishButton.translatesAutoresizingMaskIntoConstraints = false
        
        // finishButton 제약조건 설정
        // bottom 제약조건은 나중에 superview의 safeArea에 연결
        self.finishButtonBottomConstraint = self.finishButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)

        NSLayoutConstraint.activate([
            self.finishButton.topAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            self.finishButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.finishButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            self.finishButtonBottomConstraint!
        ])
        
        // superview가 설정된 후 SafeArea에 연결
        DispatchQueue.main.async { [weak self] in
            self?.updateFinishButtonConstraint()
        }

        self.contentView.addSubview(self.titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        ])

        self.contentView.addSubview(self.cancelButton)
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.cancelButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            self.cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        self.contentView.addSubview(self.tagCollectionView)
        self.tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tagCollectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 27),
            self.tagCollectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.tagCollectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.tagCollectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        ])
    }
    
    private func updateFinishButtonConstraint() {
        // finishButton의 bottom을 superview의 safeArea에 연결
        guard let superview = self.superview else { return }
        
        // 기존 제약조건 제거
        self.finishButtonBottomConstraint?.isActive = false
        
        // 새로운 제약조건 설정 (SafeArea까지 포함)
        self.finishButtonBottomConstraint = self.finishButton.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0)
        self.finishButtonBottomConstraint?.isActive = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            self.updateFinishButtonConstraint()
        }
    }
    
    private func updateViewHeight() {
        guard let filterType = self.filterType else { return }
        
        let itemCount = filterType.filterList.count
        let itemsPerRow: CGFloat = 3 // 한 줄에 3개 아이템
        let rows = ceil(CGFloat(itemCount) / itemsPerRow)
        
        // 각 행의 높이 계산 (아이템 높이 + 간격)
        let itemHeight: CGFloat = 36
        let verticalSpacing: CGFloat = 10
        let rowHeight = itemHeight + verticalSpacing
        
        // CollectionView 높이 계산 (패딩 포함)
        let collectionViewTopPadding: CGFloat = 10
        let collectionViewBottomPadding: CGFloat = 10
        let collectionViewHeight = rows * rowHeight + collectionViewTopPadding + collectionViewBottomPadding
        
        // 전체 contentView 높이 계산
        let titleHeight: CGFloat = 24 // titleLabel top
        let titleToCollectionSpacing: CGFloat = 27
        let totalContentViewHeight = titleHeight + titleToCollectionSpacing + collectionViewHeight
        
        // 최소 높이 보장
        let minContentViewHeight: CGFloat = 182
        
        // finishButton 높이 (SafeArea 포함)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let bottomSafeArea = window.safeAreaInsets.bottom
        let finishButtonBaseHeight: CGFloat = 62
        let finishButtonHeight: CGFloat = finishButtonBaseHeight + bottomSafeArea // SafeArea 높이 포함
        
        // 최대 높이 제한 (화면 상단 여유 공간 + 하단 safe area 보장)
        let topMargin: CGFloat = 100 // 상단 여유 공간
        let maxContentHeight = window.frame.height - topMargin - finishButtonHeight - 20 // 추가 여유 공간
        
        // contentView 높이 결정 (최소, 계산된 높이, 최대 높이 중)
        let finalContentViewHeight = max(minContentViewHeight, min(totalContentViewHeight, maxContentHeight))
        
        // 제약조건 업데이트
        self.contentViewHeightConstraint?.constant = finalContentViewHeight
        
        // 애니메이션과 함께 높이 업데이트
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
        
        // CollectionView가 스크롤 가능하도록 contentSize 강제 업데이트
        self.tagCollectionView.layoutIfNeeded()
    }

    @objc private func finishButtonTouchUp(sender: UIButton) {
        self.delegate?.finishButtonDidSelected(self, selectedList: self.didSelectedFilterList.map { $0.key })
    }

    @objc private func cancelButtonTouchUp(sender: UIButton) {
        self.delegate?.cancelButtonDidSelected(self, selectedList: self.didSelectedFilterList.map { $0.key })
    }
}

extension FilterDetailView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let filterType = self.filterType else { return }
        guard let tagLabelTitle = filterType.filterList[safe: indexPath.item] else { return }
        self.didSelectedFilterList[tagLabelTitle] = filterType
        let finishButtonTitle = self.didSelectedFilterList.isEmpty ? "선택" : "선택 완료"
        self.finishButton.setTitle(finishButtonTitle, for: .normal)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let filterType = self.filterType else { return }
        guard let tagLabelTitle = filterType.filterList[safe: indexPath.item] else { return }
        self.didSelectedFilterList[tagLabelTitle] = nil
        let finishButtonTitle = self.didSelectedFilterList.isEmpty ? "선택" : "필터적용하기 (데이터필요)"
        self.finishButton.setTitle(finishButtonTitle, for: .normal)
    }
}

extension FilterDetailView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterType?.filterList.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterDetailTagCollectionViewCell", for: indexPath) as? FilterDetailTagCollectionViewCell else { return UICollectionViewCell() }

        guard let filterType = self.filterType else { return UICollectionViewCell() }
        let model = FilterDetailTagModel(title: self.filterType?.filterList[indexPath.item] ?? "", filterType: filterType)

        if !didSelectedFilterList.isEmpty {
            let keyFiterList = Set(didSelectedFilterList.keys)
            if keyFiterList.contains(model.title) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
        }
        cell.configure(model)
        
        // 마지막 셀이 로드될 때 높이 업데이트
        if indexPath.item == (self.filterType?.filterList.count ?? 0) - 1 {
            DispatchQueue.main.async { [weak self] in
                self?.updateViewHeight()
            }
        }
        
        return cell
    }
}

extension UIView {

    func debugBorder() {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 2
    }
}
