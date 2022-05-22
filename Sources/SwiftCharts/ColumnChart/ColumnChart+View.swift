//
//  ColumnChart+ChartView.swift
//  Carbon Positive
//
//  Created by Olle  Ekberg on 2022-03-20.
//

import SwiftUI

extension ColumnChart {
    public struct ChartView: View {
        @ObservedObject private var viewModel: ViewModel
        @State private var previewModeActive: Bool = false
        @State private var showSort: Bool = false
        @State private var firstValue = true
        private let backgroundColor: Color
        private let sortConfig: SortConfig
        private let maxColumnsOnScreen: Int
        
        public init(viewModel: ViewModel, backgroundColor: Color = .primaryBackground, sortConfig: SortConfig = .init(), maxColumnsOnScreen: Int = 6) {
            self.viewModel = viewModel
            self.backgroundColor = backgroundColor
            self.sortConfig = sortConfig
            self.maxColumnsOnScreen = maxColumnsOnScreen
        }
        
        public var body: some View {
            VStack(alignment: .trailing) {
                if sortConfig.shouldShow {
                    sortButton()
                        .disabled(previewModeActive)
                }
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            ZStack {
                                let width = columnWidth(geometry.size.width)
                                HStack(alignment: .bottom, spacing: spacing) {
                                    ForEach(viewModel.data, id: \.self) { data in
                                        columnChartColumn(data, geometrySize: geometry.size)
                                            .frame(width: width)
                                            .blur(radius: columnBlur(data))
                                            .opacity(columnOpacity(data))
                                            .scaleEffect(columnScale(data))
                                            .animation(.default)
                                            .onTapGesture {
                                                proxy.scrollTo(0)
                                                if previewModeActive {
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
                                        columnInfo()
                                            .padding([.top, .leading], 12)
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

//MARK: - Column Views -
private extension ColumnChart.ChartView {
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
                    List(ColumnChart.ViewModel.SortMethod.allCases, id: \.self) { method in
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
    
    func columnInfo() -> some View {
        return VStack(alignment: .leading) {
            if let data = viewModel.selectedData {
                Text(data.name)
                    .font(data.columnConfig.titleFont)
                    .foregroundColor(data.columnConfig.textColor)
                Divider()
                    .background(data.columnConfig.textColor)
                Text("\(Translations.amount): \(data.amount)")
                    .font(data.columnConfig.textFont)
                    .foregroundColor(data.columnConfig.textColor)
                let percent = Float(data.amount / viewModel.maxAmount * 100)
                Text("\(Translations.percent): \(percent)%")
                    .font(data.columnConfig.textFont)
                    .foregroundColor(data.columnConfig.textColor)
                if let additionalInfo = viewModel.selectedData?.additionalInfo {
                    ForEach(additionalInfo, id: \.self) { info in
                        Text("\(info.name): \(info.value)")
                            .font(data.columnConfig.textFont)
                            .foregroundColor(data.columnConfig.textColor)
                    }
                }
            }
            Spacer()
        }
    }
    
    func columnChartColumn(_ data: ColumnChart.Column, geometrySize: CGSize) -> some View {
        
        let height = geometrySize.height
        return VStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(data.columnConfig.backgroundColor)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(data.columnConfig.columnColor.opacity(columnOpacity(data)))
                    .frame(height: columnHeight(data, viewHeight: height), alignment: .bottom)
            }
            Text(data.name)
                .font(data.columnConfig.textFont)
                .foregroundColor(data.columnConfig.textColor)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

//MARK: - Calculations -
private extension ColumnChart.ChartView {
    func columnBlur(_ data: ColumnChart.Column) -> CGFloat {
        guard viewModel.selectedData != nil else {
            return 0
        }
        
        return data == viewModel.selectedData ? 0 : 8
    }
    
    func columnHeight(_ data: ColumnChart.Column, viewHeight: CGFloat) -> CGFloat {
        
        var percent = CGFloat(data.amount / viewModel.maxAmount)
        
        if percent < 0.02 {
            percent = 0.02
        }
        
        return viewHeight * percent
    }
    
    func columnScale(_ data: ColumnChart.Column) -> CGFloat {
        guard viewModel.selectedData != nil else {
            return 1
        }
        
        return data == viewModel.selectedData ? 1 : 0.9
    }
    
    func columnOpacity(_ data: ColumnChart.Column) -> CGFloat {
        guard viewModel.selectedData != nil else {
            return 1
        }
        
        return viewModel.selectedData == data ? 1 : 0.7
    }
    
    func columnWidth(_ width: CGFloat) -> CGFloat {
        var numberOfColumnsOnScreen: Int = viewModel.amountOfData
        
        if numberOfColumnsOnScreen > maxColumnsOnScreen {
            numberOfColumnsOnScreen = maxColumnsOnScreen
        }
        
        let width = (width / CGFloat(numberOfColumnsOnScreen))  - spacing
        
        return width
    }
}

struct ChartView_Previews: PreviewProvider {
    static let data: [ColumnChart.Column] = [ColumnChart.Column(name: "First Value", amount: 122), ColumnChart.Column(name: "Second Value", amount: 6), ColumnChart.Column(name: "Third Value", amount: 783), ColumnChart.Column(name: "Fourth Value", amount: 300, additionalInfo: [.init(name: "Extra data", value: "22"), .init(name: "Extra Data 2", value: "Looks cool!")]), ColumnChart.Column(name: "Fifth Values", amount: 12), ColumnChart.Column(name: "Sixth Values", amount: 64), ColumnChart.Column(name: "Seventh Values", amount: 1200), ColumnChart.Column(name: "Eight Value", amount: 366, additionalInfo: [.init(name: "On Extra Value", value: "This is it.")]), ColumnChart.Column(name: "Ninth Value", amount: 100), ColumnChart.Column(name: "Tenth Value", amount: 86), ColumnChart.Column(name: "Eleventh Value", amount: 1002), ColumnChart.Column(name: "Twelvth Value", amount: 14)]
    
    static let vm = ColumnChart.ViewModel(data: data, sortMethod: .smallFirst)
    static var previews: some View {
        ColumnChart.ChartView(viewModel: vm, maxColumnsOnScreen: 8)
    }
}
