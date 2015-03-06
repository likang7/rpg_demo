<GameProjectFile>
  <PropertyGroup Type="Scene" Name="shopUI" ID="62938c72-5225-4a5e-8af3-9ec127d02e11" Version="2.1.2.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Scene" FrameEvent="" Tag="42" ctype="SingleNodeObjectData">
        <Position X="0.0000" Y="0.0000" />
        <Scale ScaleX="1.0000" ScaleY="1.0000" />
        <AnchorPoint />
        <CColor A="255" R="255" G="255" B="255" />
        <Size X="1024.0000" Y="768.0000" />
        <PrePosition X="0.0000" Y="0.0000" />
        <PreSize X="0.0000" Y="0.0000" />
        <Children>
          <NodeObjectData Name="shopPanel" CanEdit="False" ActionTag="-709294039" FrameEvent="" Tag="46" LeftMargin="-1.0000" RightMargin="1.0000" TopMargin="1.0001" BottomMargin="-1.0001" TouchEnable="True" BackColorAlpha="76" ComboBoxIndex="1" ColorAngle="90.0000" ctype="PanelObjectData">
            <Position X="-1.0000" Y="-1.0001" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <AnchorPoint />
            <CColor A="255" R="255" G="255" B="255" />
            <Size X="1024.0000" Y="768.0000" />
            <PrePosition X="-0.0010" Y="-0.0013" />
            <PreSize X="1.0000" Y="1.0000" />
            <Children>
              <NodeObjectData Name="bg" CanEdit="False" ActionTag="1757461248" FrameEvent="" Tag="45" LeftMargin="127.0000" RightMargin="297.0000" TopMargin="193.0000" BottomMargin="325.0000" Scale9Enable="True" LeftEage="32" RightEage="32" TopEage="32" BottomEage="32" Scale9OriginX="32" Scale9OriginY="32" Scale9Width="32" Scale9Height="32" ctype="ImageViewObjectData">
                <Position X="427.0000" Y="450.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="600.0000" Y="250.0000" />
                <PrePosition X="0.4170" Y="0.5859" />
                <PreSize X="0.5859" Y="0.3255" />
                <FileData Type="Normal" Path="shopUI.png" />
              </NodeObjectData>
              <NodeObjectData Name="contentLabel" ActionTag="695148074" FrameEvent="" Tag="48" LeftMargin="168.3290" RightMargin="327.6710" TopMargin="226.0096" BottomMargin="469.9904" IsCustomSize="True" FontSize="24" LabelText="花费金币买属性，世间难得的好事儿，走过路过不&#xA;要错过哟！&#xA;随便挑随便选，每样只要30金币！（ESC键离开）" ctype="TextObjectData">
                <Position X="432.3290" Y="505.9904" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="0" G="0" B="0" />
                <Size X="528.0000" Y="72.0000" />
                <PrePosition X="0.4222" Y="0.6588" />
                <PreSize X="0.0000" Y="0.0000" />
              </NodeObjectData>
              <NodeObjectData Name="hintLabel" ActionTag="951288851" VisibleForFrame="False" FrameEvent="" Tag="51" LeftMargin="358.5000" RightMargin="555.5000" TopMargin="386.5000" BottomMargin="359.5000" FontSize="22" LabelText="购买成功！" HorizontalAlignmentType="HT_Center" ctype="TextObjectData">
                <Position X="413.5000" Y="370.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="0" G="255" B="34" />
                <Size X="110.0000" Y="22.0000" />
                <PrePosition X="0.4038" Y="0.4824" />
                <PreSize X="0.0977" Y="0.0260" />
              </NodeObjectData>
              <NodeObjectData Name="coinShopPanel" ActionTag="-1006325303" VisibleForFrame="False" FrameEvent="" Tag="67" LeftMargin="155.0000" RightMargin="329.0000" TopMargin="316.0000" BottomMargin="380.0000" TouchEnable="True" BackColorAlpha="102" ColorAngle="90.0000" ctype="PanelObjectData">
                <Position X="155.0000" Y="380.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="540.0000" Y="72.0000" />
                <PrePosition X="0.1514" Y="0.4948" />
                <PreSize X="0.5273" Y="0.0938" />
                <Children>
                  <NodeObjectData Name="btn1" ActionTag="678014824" FrameEvent="" Tag="49" LeftMargin="40.0000" RightMargin="380.0000" TopMargin="11.0000" BottomMargin="11.0000" TouchEnable="True" FontSize="20" ButtonText="攻击+5" Scale9Enable="True" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                    <Position X="100.0000" Y="36.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="120.0000" Y="50.0000" />
                    <PrePosition X="0.1852" Y="0.5000" />
                    <PreSize X="0.1172" Y="0.0651" />
                    <TextColor A="255" R="0" G="0" B="0" />
                    <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                    <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                    <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
                  </NodeObjectData>
                  <NodeObjectData Name="btn2" ActionTag="-794180487" FrameEvent="" Tag="50" LeftMargin="210.0000" RightMargin="210.0000" TopMargin="11.0000" BottomMargin="11.0000" TouchEnable="True" FontSize="20" ButtonText="防御+5" Scale9Enable="True" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                    <Position X="270.0000" Y="36.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="120.0000" Y="50.0000" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.1172" Y="0.0651" />
                    <TextColor A="255" R="0" G="0" B="0" />
                    <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                    <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                    <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
                  </NodeObjectData>
                  <NodeObjectData Name="btn3" ActionTag="308411237" FrameEvent="" Tag="51" LeftMargin="380.0000" RightMargin="40.0000" TopMargin="11.0000" BottomMargin="11.0000" TouchEnable="True" FontSize="20" ButtonText="生命+100" Scale9Enable="True" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                    <Position X="440.0000" Y="36.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="120.0000" Y="50.0000" />
                    <PrePosition X="0.8148" Y="0.5000" />
                    <PreSize X="0.1172" Y="0.0651" />
                    <TextColor A="255" R="0" G="0" B="0" />
                    <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                    <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                    <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
                  </NodeObjectData>
                </Children>
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </NodeObjectData>
              <NodeObjectData Name="expShopPanel" ActionTag="-1654927091" VisibleForFrame="False" FrameEvent="" Tag="62" LeftMargin="155.0000" RightMargin="329.0000" TopMargin="316.0000" BottomMargin="380.0000" TouchEnable="True" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Position X="155.0000" Y="380.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="540.0000" Y="72.0000" />
                <PrePosition X="0.1514" Y="0.4948" />
                <PreSize X="0.5273" Y="0.0938" />
                <Children>
                  <NodeObjectData Name="btn1" ActionTag="-1580206518" FrameEvent="" Tag="63" LeftMargin="8.0000" RightMargin="400.0000" TopMargin="11.0000" BottomMargin="11.0000" TouchEnable="True" FontSize="20" ButtonText="攻击+5" Scale9Enable="True" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                    <Position X="68.0000" Y="36.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="120.0000" Y="50.0000" />
                    <PrePosition X="0.1288" Y="0.5000" />
                    <PreSize X="0.1172" Y="0.0651" />
                    <TextColor A="255" R="0" G="0" B="0" />
                    <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                    <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                    <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
                  </NodeObjectData>
                  <NodeObjectData Name="btn2" ActionTag="-905396628" FrameEvent="" Tag="64" LeftMargin="143.0000" RightMargin="265.0000" TopMargin="11.0000" BottomMargin="11.0000" TouchEnable="True" FontSize="20" ButtonText="攻击+5" Scale9Enable="True" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                    <Position X="203.0000" Y="36.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="120.0000" Y="50.0000" />
                    <PrePosition X="0.3845" Y="0.5000" />
                    <PreSize X="0.1172" Y="0.0651" />
                    <TextColor A="255" R="0" G="0" B="0" />
                    <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                    <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                    <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
                  </NodeObjectData>
                  <NodeObjectData Name="btn3" ActionTag="-1286898449" FrameEvent="" Tag="65" LeftMargin="278.0000" RightMargin="130.0000" TopMargin="11.0000" BottomMargin="11.0000" TouchEnable="True" FontSize="20" ButtonText="攻击+5" Scale9Enable="True" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                    <Position X="338.0000" Y="36.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="120.0000" Y="50.0000" />
                    <PrePosition X="0.6402" Y="0.5000" />
                    <PreSize X="0.1172" Y="0.0651" />
                    <TextColor A="255" R="0" G="0" B="0" />
                    <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                    <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                    <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
                  </NodeObjectData>
                  <NodeObjectData Name="btn4" ActionTag="918084902" FrameEvent="" Tag="66" LeftMargin="413.0000" RightMargin="-5.0000" TopMargin="11.0000" BottomMargin="11.0000" TouchEnable="True" FontSize="20" ButtonText="攻击+5" Scale9Enable="True" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
                    <Position X="473.0000" Y="36.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="120.0000" Y="50.0000" />
                    <PrePosition X="0.8958" Y="0.5000" />
                    <PreSize X="0.1172" Y="0.0651" />
                    <TextColor A="255" R="0" G="0" B="0" />
                    <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
                    <PressedFileData Type="Default" Path="Default/Button_Press.png" />
                    <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
                  </NodeObjectData>
                </Children>
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </NodeObjectData>
            </Children>
            <SingleColor A="255" R="155" G="155" B="155" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </NodeObjectData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameProjectFile>