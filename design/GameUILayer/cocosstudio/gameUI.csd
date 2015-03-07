<GameProjectFile>
  <PropertyGroup Type="Layer" Name="gameUI" ID="916806cf-7ce3-4d83-bd4c-66748f19fc90" Version="2.1.2.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Layer" FrameEvent="" ctype="LayerObjectData">
        <Position X="0.0000" Y="0.0000" />
        <Scale ScaleX="1.0000" ScaleY="1.0000" />
        <AnchorPoint />
        <CColor A="255" R="255" G="255" B="255" />
        <Size X="1024.0000" Y="768.0000" />
        <PrePosition X="0.0000" Y="0.0000" />
        <PreSize X="0.0000" Y="0.0000" />
        <Children>
          <NodeObjectData Name="InfoPanel" ActionTag="498652306" FrameEvent="" Tag="5" LeftMargin="768.0000" TopMargin="-0.0001" BottomMargin="0.0001" TouchEnable="True" BackColorAlpha="102" ColorAngle="90.0000" ctype="PanelObjectData">
            <Position X="768.0000" Y="0.0001" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <AnchorPoint />
            <CColor A="255" R="255" G="255" B="255" />
            <Size X="256.0000" Y="768.0000" />
            <PrePosition X="0.7500" Y="0.0000" />
            <PreSize X="0.2500" Y="1.0000" />
            <Children>
              <NodeObjectData Name="bg" CanEdit="False" ActionTag="-1938293779" FrameEvent="" Tag="6" Scale9Width="256" Scale9Height="768" ctype="ImageViewObjectData">
                <Position X="0.0000" Y="0.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="256.0000" Y="768.0000" />
                <PrePosition X="0.0000" Y="0.0000" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui.png" />
              </NodeObjectData>
              <NodeObjectData Name="heroInfo" CanEdit="False" ActionTag="1014295721" FrameEvent="" Tag="27" LeftMargin="-2.5006" RightMargin="2.5006" TopMargin="28.0000" BottomMargin="440.0000" BackColorAlpha="0" ColorAngle="90.0000" ctype="PanelObjectData">
                <Position X="-2.5006" Y="440.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="256.0000" Y="300.0000" />
                <PrePosition X="-0.0098" Y="0.5729" />
                <PreSize X="1.0000" Y="0.3906" />
                <Children>
                  <NodeObjectData Name="heroHead" ActionTag="58852323" FrameEvent="" Tag="7" Scale9Width="120" Scale9Height="120" ctype="ImageViewObjectData">
                    <Position X="45.9994" Y="175.9770" />
                    <Scale ScaleX="0.6000" ScaleY="0.6000" />
                    <AnchorPoint />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="120.0000" Y="120.0000" />
                    <PrePosition X="0.1797" Y="0.5866" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="heroIcon.jpg" />
                  </NodeObjectData>
                  <NodeObjectData Name="heroName" ActionTag="1661035499" FrameEvent="" Tag="8" FontSize="24" LabelText="牛魔王" ctype="TextObjectData">
                    <Position X="125.9994" Y="208.9738" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="72.0000" Y="24.0000" />
                    <PrePosition X="0.4922" Y="0.6966" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="heroLevel" ActionTag="1579759903" FrameEvent="" Tag="9" FontSize="24" LabelText="Lv.300" ctype="TextObjectData">
                    <Position X="125.9994" Y="176.9773" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="72.0000" Y="24.0000" />
                    <PrePosition X="0.4922" Y="0.5899" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3" ActionTag="-1991177769" FrameEvent="" Tag="11" LeftMargin="48.4993" RightMargin="157.5007" TopMargin="188.0159" BottomMargin="91.9841" FontSize="20" LabelText="攻击:" ctype="TextObjectData">
                    <Position X="48.4993" Y="91.9841" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1895" Y="0.3066" />
                    <PreSize X="0.1953" Y="0.0667" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy" ActionTag="-1417782404" FrameEvent="" Tag="12" FontSize="20" LabelText="防御:" ctype="TextObjectData">
                    <Position X="48.4993" Y="71.9870" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1895" Y="0.2400" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy_0" ActionTag="90454359" FrameEvent="" Tag="13" FontSize="20" LabelText="生命:" ctype="TextObjectData">
                    <Position X="48.4993" Y="51.9892" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1895" Y="0.1733" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy_1" ActionTag="-680969248" FrameEvent="" Tag="14" FontSize="20" LabelText="暴击:" ctype="TextObjectData">
                    <Position X="48.4993" Y="31.9903" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1895" Y="0.1066" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy_2" ActionTag="-723312987" FrameEvent="" Tag="15" FontSize="20" LabelText="防爆:" ctype="TextObjectData">
                    <Position X="48.4993" Y="11.9914" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1895" Y="0.0400" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="attackLabel" ActionTag="1725616045" FrameEvent="" Tag="16" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="98.4993" Y="91.9841" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3848" Y="0.3066" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="defenseLabel" ActionTag="-1614988532" FrameEvent="" Tag="17" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="98.4993" Y="71.9870" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3848" Y="0.2400" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="hpLabel" ActionTag="379747984" FrameEvent="" Tag="18" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="98.4993" Y="51.9892" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3848" Y="0.1733" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="criticalLabel" ActionTag="814520017" FrameEvent="" Tag="19" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="98.4993" Y="31.9903" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3848" Y="0.1066" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="antiCriticalLabel" ActionTag="546852217" FrameEvent="" Tag="20" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="98.4993" Y="11.9914" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3848" Y="0.0400" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy_3" ActionTag="-729999134" FrameEvent="" Tag="21" FontSize="20" LabelText="经验:" ctype="TextObjectData">
                    <Position X="48.4993" Y="142.9772" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1895" Y="0.4766" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy_Copy" ActionTag="-1052322901" FrameEvent="" Tag="22" FontSize="20" LabelText="金币:" ctype="TextObjectData">
                    <Position X="48.4993" Y="122.9819" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1895" Y="0.4099" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="expLabel" ActionTag="2011292319" FrameEvent="" Tag="23" FontSize="20" LabelText="100000000000" ctype="TextObjectData">
                    <Position X="98.4993" Y="142.9772" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="120.0000" Y="20.0000" />
                    <PrePosition X="0.3848" Y="0.4766" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="coinLabel" ActionTag="964333631" FrameEvent="" Tag="24" FontSize="20" LabelText="100000000000" ctype="TextObjectData">
                    <Position X="98.4993" Y="122.9819" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="120.0000" Y="20.0000" />
                    <PrePosition X="0.3848" Y="0.4099" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                </Children>
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </NodeObjectData>
              <NodeObjectData Name="monsterInfo" ActionTag="181202759" FrameEvent="" Tag="28" LeftMargin="-2.5006" RightMargin="2.5006" TopMargin="318.0000" BottomMargin="200.0000" BackColorAlpha="102" ColorAngle="90.0000" ctype="PanelObjectData">
                <Position X="-2.5006" Y="200.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="256.0000" Y="250.0000" />
                <PrePosition X="-0.0098" Y="0.2604" />
                <PreSize X="1.0000" Y="0.3255" />
                <Children>
                  <NodeObjectData Name="heroName" ActionTag="-599183131" FrameEvent="" Tag="30" FontSize="24" LabelText="牛魔王" ctype="TextObjectData">
                    <Position X="125.9994" Y="181.9774" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="72.0000" Y="24.0000" />
                    <PrePosition X="0.4922" Y="0.7279" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="heroLevel" ActionTag="717580176" FrameEvent="" Tag="31" FontSize="24" LabelText="Lv.300" ctype="TextObjectData">
                    <Position X="125.9994" Y="149.9810" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="72.0000" Y="24.0000" />
                    <PrePosition X="0.4922" Y="0.5999" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3" ActionTag="-1273481768" FrameEvent="" Tag="32" FontSize="20" LabelText="攻击:" ctype="TextObjectData">
                    <Position X="45.9933" Y="113.9821" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1797" Y="0.4559" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy" ActionTag="-893022292" FrameEvent="" Tag="33" FontSize="20" LabelText="防御:" ctype="TextObjectData">
                    <Position X="45.9933" Y="93.9853" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1797" Y="0.3759" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy_0" ActionTag="-290903432" FrameEvent="" Tag="34" FontSize="20" LabelText="生命:" ctype="TextObjectData">
                    <Position X="45.9933" Y="73.9857" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1797" Y="0.2959" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy_1" ActionTag="182380551" FrameEvent="" Tag="35" FontSize="20" LabelText="暴击:" ctype="TextObjectData">
                    <Position X="45.9933" Y="53.9875" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1797" Y="0.2159" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="Text_3_Copy_2" ActionTag="-284023707" FrameEvent="" Tag="36" LeftMargin="45.9932" RightMargin="160.0068" TopMargin="196.0100" BottomMargin="33.9900" FontSize="20" LabelText="防爆:" ctype="TextObjectData">
                    <Position X="45.9932" Y="33.9900" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="50.0000" Y="20.0000" />
                    <PrePosition X="0.1797" Y="0.1360" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="attackLabel" ActionTag="2040066167" FrameEvent="" Tag="37" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="95.9933" Y="113.9821" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3750" Y="0.4559" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="defenseLabel" ActionTag="-2013965637" FrameEvent="" Tag="38" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="95.9933" Y="93.9853" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3750" Y="0.3759" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="hpLabel" ActionTag="876728424" FrameEvent="" Tag="39" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="95.9933" Y="73.9857" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3750" Y="0.2959" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="criticalLabel" ActionTag="-1913134853" FrameEvent="" Tag="40" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="95.9933" Y="53.9875" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3750" Y="0.2159" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="antiCriticalLabel" ActionTag="557927119" FrameEvent="" Tag="41" FontSize="20" LabelText="10000000" ctype="TextObjectData">
                    <Position X="95.9933" Y="33.9879" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="0" G="0" B="0" />
                    <Size X="80.0000" Y="20.0000" />
                    <PrePosition X="0.3750" Y="0.1360" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </NodeObjectData>
                  <NodeObjectData Name="heroHead" ActionTag="-2036288965" FrameEvent="" Tag="29" LeftMargin="45.9994" RightMargin="138.0006" TopMargin="29.0188" BottomMargin="148.9812" Scale9Width="120" Scale9Height="120" ctype="ImageViewObjectData">
                    <Position X="45.9994" Y="148.9812" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="72.0000" Y="72.0000" />
                    <PrePosition X="0.1797" Y="0.5959" />
                    <PreSize X="0.2813" Y="0.2880" />
                    <FileData Type="Normal" Path="heroIcon.jpg" />
                  </NodeObjectData>
                </Children>
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </NodeObjectData>
              <NodeObjectData Name="tips1" ActionTag="565035448" FrameEvent="" Tag="26" FontSize="16" LabelText="Tips：&#xA;1. Tab查看怪物警戒范围&#xA;&#xA;2. 消灭怪物后方可拾取&#xA;   警戒范围内的物品" ctype="TextObjectData">
                <Position X="43.4988" Y="101.9971" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint />
                <CColor A="255" R="0" G="0" B="0" />
                <Size X="176.0000" Y="80.0000" />
                <PrePosition X="0.1699" Y="0.1328" />
                <PreSize X="0.0000" Y="0.0000" />
              </NodeObjectData>
              <NodeObjectData Name="saveRecordBtn" ActionTag="1477235909" FrameEvent="" Tag="25" LeftMargin="38.9990" RightMargin="137.0010" TopMargin="682.0019" BottomMargin="49.9981" TouchEnable="True" FontSize="16" ButtonText="保存进度" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                <Position X="38.9990" Y="49.9981" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="80.0000" Y="36.0000" />
                <PrePosition X="0.1523" Y="0.0651" />
                <PreSize X="0.3125" Y="0.0469" />
                <TextColor A="255" R="0" G="0" B="0" />
                <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
              </NodeObjectData>
              <NodeObjectData Name="stageTitleLabel" ActionTag="-596407991" FrameEvent="" Tag="39" LeftMargin="39.4013" RightMargin="40.5987" TopMargin="43.0792" BottomMargin="702.9208" FontSize="22" LabelText="第一关：初始之地" ctype="TextObjectData">
                <Position X="127.4013" Y="713.9208" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="0" G="0" B="0" />
                <Size X="176.0000" Y="22.0000" />
                <PrePosition X="0.4977" Y="0.9296" />
                <PreSize X="0.0000" Y="0.0000" />
              </NodeObjectData>
              <NodeObjectData Name="returnBtn" ActionTag="-1966514805" FrameEvent="" Tag="40" LeftMargin="135.4197" RightMargin="40.5803" TopMargin="682.0000" BottomMargin="50.0000" TouchEnable="True" FontSize="16" ButtonText="返回首页" Scale9Enable="True" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                <Position X="135.4197" Y="50.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="80.0000" Y="36.0000" />
                <PrePosition X="0.5290" Y="0.0651" />
                <PreSize X="0.3125" Y="0.0469" />
                <TextColor A="255" R="0" G="0" B="0" />
                <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
              </NodeObjectData>
              <NodeObjectData Name="responseLabel" ActionTag="1951077364" VisibleForFrame="False" FrameEvent="" Tag="41" LeftMargin="80.2420" RightMargin="75.7580" TopMargin="718.2469" BottomMargin="29.7530" FontSize="18" LabelText="已成功保存！" ctype="TextObjectData">
                <Position X="130.2420" Y="39.7530" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="0" G="255" B="0" />
                <Size X="108.0000" Y="18.0000" />
                <PrePosition X="0.5088" Y="0.0518" />
                <PreSize X="0.0000" Y="0.0000" />
              </NodeObjectData>
            </Children>
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </NodeObjectData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameProjectFile>