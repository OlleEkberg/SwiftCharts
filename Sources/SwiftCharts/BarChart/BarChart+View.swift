//
//  BarChart+ChartView.swift
//  Carbon Positive
//
//  Created by Olle  Ekberg on 2022-03-20.
//

import SwiftUI

extension BarChart {
    public struct ChartView: View {
        @ObservedObject private var viewModel: ViewModel
        @State private var previewModeActive: Bool = false
        @State private var showSort: Bool = false
        @State private var firstValue = true
        private let backgroundColor: Color
        private let sortConfig: SortConfig
        private let maxBarsOnScreen: Int
        
        public init(viewModel: ViewModel, backgroundColor: Color = .primaryBackground, sortConfig: SortConfig = .init(), maxBarsOnScreen: Int = 6) {
            self.viewModel = viewModel
            self.backgroundColor = backgroundColor
            self.sortConfig = sortConfig
            self.maxBarsOnScreen = maxBarsOnScreen
        }
        
        public var body: some View {
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
}

//MARK: - Bar Views -
private extension BarChart.ChartView {
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
                    Text(Translations.sortBy)
                        .font(sortConfig.titleFont)
                        .foregroundColor(sortConfig.titleColor)
                        .padding()
                    List(BarChart.ViewModel.SortMethod.allCases, id: \.self) { method in
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
                Text("\(Translations.amount): \(data.amount)")
                    .font(data.barConfig.textFont)
                    .foregroundColor(data.barConfig.textColor)
                let percent = Float(data.amount / viewModel.maxAmount * 100)
                Text("\(Translations.percent): \(percent)%")
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
    
    func barChartBar(_ data: BarChart.Bar, geometrySize: CGSize) -> some View {
        
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
private extension BarChart.ChartView {
    func barBlur(_ data: BarChart.Bar) -> CGFloat {
        guard viewModel.selectedData != nil else {
            return 0
        }
        
        return data == viewModel.selectedData ? 0 : 8
    }
    
    func barHeight(_ data: BarChart.Bar, viewHeight: CGFloat) -> CGFloat {
        
        var percent = CGFloat(data.amount / viewModel.maxAmount)
        
        if percent < 0.02 {
            percent = 0.02
        }
        
        return viewHeight * percent
    }
    
    func barScale(_ data: BarChart.Bar) -> CGFloat {
        guard viewModel.selectedData != nil else {
            return 1
        }
        
        return data == viewModel.selectedData ? 1 : 0.9
    }
    
    func barOpacity(_ data: BarChart.Bar) -> CGFloat {
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

struct ChartView_Previews: PreviewProvider {
    static let data: [BarChart.Bar] = [BarChart.Bar(name: "First Value", amount: 122), BarChart.Bar(name: "Second Value", amount: 6), BarChart.Bar(name: "Third Value", amount: 783), BarChart.Bar(name: "Fourth Value", amount: 300, additionalInfo: [.init(name: "Extra data", value: "22"), .init(name: "Extra Data 2", value: "Looks cool!")]), BarChart.Bar(name: "Fifth Values", amount: 12), BarChart.Bar(name: "Sixth Values", amount: 64), BarChart.Bar(name: "Seventh Values", amount: 1200), BarChart.Bar(name: "Eight Value", amount: 366, additionalInfo: [.init(name: "On Extra Value", value: "This is it.")]), BarChart.Bar(name: "Ninth Value", amount: 100), BarChart.Bar(name: "Tenth Value", amount: 86), BarChart.Bar(name: "Eleventh Value", amount: 1002), BarChart.Bar(name: "Twelvth Value", amount: 14)]
    
    static let vm = BarChart.ViewModel(data: data, sortMethod: .smallFirst)
    static var previews: some View {
        BarChart.ChartView(viewModel: vm, maxBarsOnScreen: 8)
    }
}
