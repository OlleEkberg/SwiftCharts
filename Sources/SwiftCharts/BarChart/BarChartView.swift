//
//  BarChartView.swift
//  Carbon Positive
//
//  Created by Olle  Ekberg on 2022-03-20.
//

import SwiftUI

extension BarChartView {
    struct SortConfig {
        let shouldShow: Bool
        let titleFont: Font
        let titleColor: Color
        let titleBackgroundColor: Color
        let methodTextColor: Color
        let methodFont: Font
        let imageColor: Color
        let image: Image
        
        init(shouldShow: Bool = true, titleFont: Font = .largeTitle, titleColor: Color = .primaryText, titleBackgroundColor: Color = .primaryBackground, methodTextColor: Color = .buttonText, methodFont: Font = .body, imageColor: Color = .primaryText, image: Image = Image(systemName: "slider.horizontal.3")) {
            self.shouldShow = shouldShow
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.titleBackgroundColor = titleBackgroundColor
            self.methodTextColor = methodTextColor
            self.methodFont = methodFont
            self.imageColor = imageColor
            self.image = image
        }
    }
}

struct BarChartView: View {
    @ObservedObject private var viewModel: BarChartViewModel
    @State private var previewModeActive: Bool = false
    @State private var showSort: Bool = false
    private let backgroundColor: Color
    private let sortConfig: SortConfig
    private let maxBarsOnScreen: Int
    @State private var firstValue = true
    
    init(with viewModel: BarChartViewModel, backgroundColor: Color = .primaryBackground, sortConfig: SortConfig = .init(), maxBarsOnScreen: Int = 6) {
        self.viewModel = viewModel
        self.backgroundColor = backgroundColor
        self.sortConfig = sortConfig
        self.maxBarsOnScreen = maxBarsOnScreen
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            if sortConfig.shouldShow {
                sortButton()
                    .disabled(previewModeActive)
            }
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        ZStack {
                            let width = barWidth(geometry.size.width)
                            HStack(alignment: .bottom, spacing: spacing) {
                                ForEach(viewModel.data, id: \.self) { data in
                                    barChartBar(data, geometrySize: geometry.size)
                                        .frame(width: width)
                                        .blur(radius: barBlur(data))
                                        .opacity(barOpacity(data))
                                        .scaleEffect(barScale(data))
                                        .animation(.default)
                                        .onTapGesture {
                                            proxy.scrollTo(0)
                                            if previewModeActive{
                                                viewModel.didReset(data: data)
                                                previewModeActive = false
                                            } else {
                                                viewModel.didSelect(data: data)
                                                previewModeActive = true
                                            }
                                        }
                                        .id(firstValue ? 0 : nil)
                                        .onDisappear {
                                            firstValue = false
                                        }
                                }
                            }
                            if previewModeActive {
                                HStack {
                                    Spacer(minLength: width)
                                    barInfo()
                                        .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 0))
                                }
                            }
                        }
                    }
                }

            }
        }
        .background(backgroundColor)
    }
    
    // Constants
    let spacing: CGFloat = 2
    let padding: CGFloat = 4
    let cornerRadius: CGFloat = 8
}

//MARK: - Bar Views -
private extension BarChartView {
    func sortButton() -> some View {
        return sortConfig.image
            .frame(alignment: .trailing)
            .scaledToFit()
            .padding()
            .foregroundColor(sortConfig.imageColor)
            .onTapGesture {
                showSort = true
            }
            .sheet(isPresented: $showSort) {
                VStack {
                    Text(BarChartTranslations.sortBy)
                        .font(sortConfig.titleFont)
                        .foregroundColor(sortConfig.titleColor)
                        .padding()
                    List(BarChartViewModel.SortMethod.allCases, id: \.self) { method in
                        let disabled = method == viewModel.currentSortMethod
                        Button(method.name) {
                            viewModel.sort(by: method)
                            showSort = false
                        }
                        .foregroundColor(disabled ? .none : sortConfig.methodTextColor)
                        .disabled(disabled)
                        .font(sortConfig.methodFont)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .background(sortConfig.titleBackgroundColor)
            }
    }
    
    func barInfo() -> some View {
        return VStack(alignment: .leading) {
            if let data = viewModel.selectedData {
                Text(data.name)
                    .font(data.barConfig.titleFont)
                    .foregroundColor(data.barConfig.textColor)
                Divider()
                    .background(data.barConfig.textColor)
                Text("\(BarChartTranslations.amount): \(data.amount)")
                    .font(data.barConfig.textFont)
                    .foregroundColor(data.barConfig.textColor)
                let percent = Float(data.amount / viewModel.maxValue * 100)
                Text("\(BarChartTranslations.percent): \(percent)%")
                    .font(data.barConfig.textFont)
                    .foregroundColor(data.barConfig.textColor)
                if let additionalInfo = viewModel.selectedData?.additionalInfo {
                    ForEach(additionalInfo, id: \.self) { info in
                        Text("\(info.name): \(info.value)")
                            .font(data.barConfig.textFont)
                            .foregroundColor(data.barConfig.textColor)
                    }
                }
            }
            Spacer()
        }
    }
    
    func barChartBar(_ data: BarData, geometrySize: CGSize) -> some View {
        
        let height = geometrySize.height
        return VStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(data.barConfig.backgroundColor)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(data.barConfig.barColor.opacity(barOpacity(data)))
                    .frame(height: barHeight(data, viewHeight: height), alignment: .bottom)
            }
            Text(data.name)
                .font(data.barConfig.textFont)
                .foregroundColor(data.barConfig.textColor)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

//MARK: - Calculations -
private extension BarChartView {
    func barBlur(_ data: BarData) -> CGFloat {
        guard viewModel.selectedData != nil else {
            return 0
        }
        
        return data == viewModel.selectedData ? 0 : 8
    }
    
    func barHeight(_ data: BarData, viewHeight: CGFloat) -> CGFloat {
        
        var percent = CGFloat(data.amount / viewModel.maxValue)
        
        if percent < 0.02 {
            percent = 0.02
        }
        
        return viewHeight * percent
    }
    
    func barScale(_ data: BarData) -> CGFloat {
        guard viewModel.selectedData != nil else {
            return 1
        }
        
        return data == viewModel.selectedData ? 1 : 0.9
    }
    
    func barOpacity(_ data: BarData) -> CGFloat {
        guard viewModel.selectedData != nil else {
            return 1
        }
        
        return viewModel.selectedData == data ? 1 : 0.7
    }
    
    func barWidth(_ width: CGFloat) -> CGFloat {
        var numberOfBarsOnScreen: Int = viewModel.amountOfData
        
        if numberOfBarsOnScreen > maxBarsOnScreen {
            numberOfBarsOnScreen = maxBarsOnScreen
        }
        
        let width = (width / CGFloat(numberOfBarsOnScreen))  - spacing
        
        return width
    }
}

struct BarChartView_Previews: PreviewProvider {
    static let data: [BarData] = [BarData(name: "First Values", amount: 122), BarData(name: "Second Values", amount: 6), BarData(name: "Third Values", amount: 783), BarData(name: "Fourth Values", amount: 300, additionalInfo: [.init(name: "Hej", value: "Okej"), .init(name: "Jaså", value: "jajaja")]), BarData(name: "First Values", amount: 122), BarData(name: "Second Values", amount: 6), BarData(name: "Third Values", amount: 783), BarData(name: "Fourth Values", amount: 300, additionalInfo: [.init(name: "Hej", value: "Okej"), .init(name: "Jaså", value: "jajaja")]), BarData(name: "First Values", amount: 122), BarData(name: "Second Values", amount: 6), BarData(name: "Third Values", amount: 783), BarData(name: "Fourth Values", amount: 300, additionalInfo: [.init(name: "Hej", value: "Okej"), .init(name: "Jaså", value: "jajaja")])]
    
    static let vm = BarChartViewModel(data: data, sortMethod: .smallFirst)
    static var previews: some View {
        BarChartView(with: vm, maxBarsOnScreen: 8).preferredColorScheme(.dark)
    }
}
