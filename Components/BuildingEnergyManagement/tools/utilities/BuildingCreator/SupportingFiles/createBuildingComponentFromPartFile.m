function [mdlBlkPath,msgDisplayCount] = createBuildingComponentFromPartFile(NameValueArgs)
% Create building model from XML file
% 
% Copyright 2025 The MathWorks, Inc.

    arguments
        NameValueArgs.BuildingPartFile string {mustBeNonempty}
        NameValueArgs.BuildingLibraryName string {mustBeNonempty}
        NameValueArgs.ModelType string {mustBeMember(NameValueArgs.ModelType,["Heat Load Analysis","Building Energy System (TL)"])} = "Heat Load Analysis"
        NameValueArgs.Diagnostics logical {mustBeNumericOrLogical} = false
        NameValueArgs.OnlyBlockNameOutput logical {mustBeNumericOrLogical} = true
        NameValueArgs.DiagnosticMsgStart (1,1) {mustBeNonnegative} = 0
    end
    
    msgDisplayCount = NameValueArgs.DiagnosticMsgStart;
    msgDisplayCount = displayDiagnostics(ErrorMsg="Starting to read the building part file",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
    apartment3D = readBuildingDataXML(FileName=NameValueArgs.BuildingPartFile);
    
    msgDisplayCount = displayDiagnostics(ErrorMsg="Completed reading building part file",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
    
    [nApt, nRooms] = getNumAptAndRoomsFromFloorPlan(apartment3D);
    if NameValueArgs.ModelType == "Heat Load Analysis"
        for i = 1:nApt
            for j = 1:nRooms(i,1)
                if isfield(apartment3D.("apartment"+i).("room"+j).physics,"underfloor")
                    apartment3D.("apartment"+i).("room"+j).physics = rmfield(apartment3D.("apartment"+i).("room"+j).physics,"underfloor");
                end
                if isfield(apartment3D.("apartment"+i).("room"+j).physics,"radiator")
                    apartment3D.("apartment"+i).("room"+j).physics = rmfield(apartment3D.("apartment"+i).("room"+j).physics,"radiator");
                end
            end
        end
        msgDisplayCount = displayDiagnostics(ErrorMsg="Removed all Radiator and Under Floor Piping data from the  building part file",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
    end
    
    setLibraryPathReferences;
    
    scaleToPlot = 200;
    accomodateWall = 0.25;
    wallSubsystemDim = 20;
    labelSize = 6;
    spacingVal = 100;
    spacingFromMaxX = 8;
    spacingFromMinX = 4;
    sizeVal = 30;
    sizeArrayNodeConn = 50;
    
    if bdIsLoaded(NameValueArgs.BuildingLibraryName), bdclose(NameValueArgs.BuildingLibraryName); end

    msgDisplayCount = displayDiagnostics(ErrorMsg="Opening Simulink...",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

    new_system(NameValueArgs.BuildingLibraryName,"Library");
    open_system(NameValueArgs.BuildingLibraryName);
    
    msgDisplayCount = displayDiagnostics(ErrorMsg=strcat("Opened model ",NameValueArgs.BuildingLibraryName,".slx to create building library"),ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

    topFloorLevelNum = apartment3D.apartment1.room1.geometry.dim.topFloorLevelNum;
    
    % Initialize data to store block paths for the model
    mdlBlkPath = initializeModelBlockPathMatrices(BuildingModel=apartment3D);
    % Create subsystem for ground, roof, floors, and building floor level plans
    [mdlBlkPath.blkNameFloorLevel,...
     mdlBlkPath.blkNameFloorConn,...
     mdlBlkPath.libBuildingPath,...
     mdlBlkPath.levelSubsysLoc] = addFloorLevelSubsystem(...
                                        BuildingModel=apartment3D,...
                                        ModelName=NameValueArgs.BuildingLibraryName);

    msgDisplayCount = displayDiagnostics(ErrorMsg="Create subsystem for ground, roof, floors, and building floor level plans",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

    % Find apartment and room indices per floor level
    indxAptRoom = getAptRoomNumForGivenFloor(BuildingData=apartment3D);
    fullListOfRooms = getListOfAllRoomsBuilding(BuildingData=apartment3D);
    fullListRoomPhys = iniPhysicsForAllRoomsBuilding(RoomList=fullListOfRooms);
    
    for floorLevelNum = 1:topFloorLevelNum
        % Find list of apartment and rooms to consider at the floor level
        listofRooms = reshape(indxAptRoom(floorLevelNum,:),[2,length(indxAptRoom(floorLevelNum,:))/2])';
    
        if floorLevelNum == topFloorLevelNum
            % Add solar port for Roof definition
            portR = addPortToCanvas(CanvasLocation=mdlBlkPath.blkNameFloorConn(topFloorLevelNum+1,1),...
                PortName="Solar",PortSide="left",...
                PortLocation=[minX-spacingFromMinX*spacingVal 3*spacingVal minX-spacingFromMinX*spacingVal+sizeVal 3*spacingVal+sizeVal]);
        end
    
        % Find floor level rooms and re-create floorplan.
        for idx = 1:size(listofRooms,1)
            i = listofRooms(idx,1);
            j = listofRooms(idx,2);

            % mdlBlkPath.nodesPerFloorLvl(:,i): i=1 stores # Thermal Nodes
            %                                   i=2 stores # TL nodes
            mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1) = mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1)+1;
            % The room or floorplan might have been rotated (XML definition) and hence
            % it is important to realign them to X-Y axis.
            roomJvert = getNonRotatedRoomVertices(Apartment=apartment3D,NumberApartment=i,NumberRoom=j);
            mdlBlkPath.areaNameRoom(i,j) = strcat(mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),"/A",num2str(i),"R",num2str(j)," (",apartment3D.("apartment"+i).("room"+j).name,")");
            nonRotatedLoc = [roomJvert(1,:),roomJvert(3,:)]*scaleToPlot;
            mdlBlkPath.areaNameRoomLoc(i,j) = num2str(nonRotatedLoc);
            areaColor = [0.99*max(0.9,rand(1)) 0.88*max(0.9,rand(1)) 0.99*max(0.9,rand(1)) 0.88*max(0.9,rand(1))];
            add_block("built-in/Area",mdlBlkPath.areaNameRoom(i,j),"Position",nonRotatedLoc,"BackgroundColor", mat2str(areaColor));
            % To plot rooms, you must first find their non-rotated vertices and data 
            % that align along the X and Y axes.
            delX = (nonRotatedLoc(1,3)-nonRotatedLoc(1,1))*accomodateWall; % Calculate delX from diagonal vertices
            delY = (nonRotatedLoc(1,4)-nonRotatedLoc(1,2))*accomodateWall; % Calculate delY from diagonal vertices
            roomJvertNonRotated = [nonRotatedLoc(1,1)+delX, nonRotatedLoc(1,2)+delY,nonRotatedLoc(1,3)-delX, nonRotatedLoc(1,4)-delY];
            roomNameDisp = apartment3D.("apartment"+i).("room"+j).name;
            if floorLevelNum == 1
                mdlBlkPath.areaNameGround(i,j) = addFloorOrRoofElement(WallName=strcat("Ground_A",num2str(i),"R",num2str(j),"(",roomNameDisp,")"),...
                    DisplayColor=areaColor,WallLocation=roomJvertNonRotated,WallBoundaryLocation=nonRotatedLoc,...
                    WallSubsystemPath=mdlBlkPath.blkNameFloorConn(1,1),WallType="Solid Wall");
            end
            if floorLevelNum == topFloorLevelNum
               mdlBlkPath.areaNameRoof(i,j) = addFloorOrRoofElement(WallName=strcat("Roof_A",num2str(i),"R",num2str(j),"(",roomNameDisp,")"),...
                    DisplayColor=areaColor,WallLocation=roomJvertNonRotated,WallBoundaryLocation=nonRotatedLoc,...
                    WallSubsystemPath=mdlBlkPath.blkNameFloorConn(floorLevelNum+1,1),WallType="Solid Wall with Solar");
               % Connect roof elements to solar port
               % The roof is Ext Wall element and the port name is R, and
               % NOT 'S' as in other Wall Selector components.
               simscape.addConnection(mdlBlkPath.areaNameRoof(i,j),"R",portR,"port","autorouting","on");
            else
               mdlBlkPath.areaNameRoof(i,j) = addFloorOrRoofElement(WallName=strcat("Floor_A",num2str(i),"R",num2str(j),"(",roomNameDisp,")"),...
                    DisplayColor=areaColor,WallLocation=roomJvertNonRotated,WallBoundaryLocation=nonRotatedLoc,...
                    WallSubsystemPath=mdlBlkPath.blkNameFloorConn(floorLevelNum+1,1),WallType="Solid Wall");
            end
    
            if isfield(apartment3D.("apartment"+i).("room"+j).physics,"underfloor") && isfield(apartment3D.("apartment"+i).("room"+j).physics,"radiator")
                % Both radiator and underfloor piping
                fullListRoomPhys(and(fullListRoomPhys(:,1)==i,fullListRoomPhys(:,2)==j),3) = 3;
                blkName = strcat(mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),strcat("/RoomRadUFP_A",num2str(i),"R",num2str(j),"_",roomNameDisp));
                blkLibType = "Room with UFP & Radiator"; % ["Room","Room with Radiator","Room with UFP","Room with UFP & Radiator"]
                add_block(customBlkPath.roomRadUFP,blkName,"Position",roomJvertNonRotated);
                mdlBlkPath.blkNameBldgPhys(i,j) = 1;
                mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2) = mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2)+1;
            elseif isfield(apartment3D.("apartment"+i).("room"+j).physics,"underfloor") && ~isfield(apartment3D.("apartment"+i).("room"+j).physics,"radiator")
                % Underfloor piping only
                fullListRoomPhys(and(fullListRoomPhys(:,1)==i,fullListRoomPhys(:,2)==j),3) = 2;
                blkName = strcat(mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),strcat("/RoomUFP_A",num2str(i),"R",num2str(j),"_",roomNameDisp));
                blkLibType = "Room with UFP"; % ["Room","Room with Radiator","Room with UFP","Room with UFP & Radiator"]
                add_block(customBlkPath.roomUFP,blkName,"Position",roomJvertNonRotated);
                mdlBlkPath.blkNameBldgPhys(i,j) = 1;
                mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2) = mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2)+1;
            elseif isfield(apartment3D.("apartment"+i).("room"+j).physics,"radiator") && ~isfield(apartment3D.("apartment"+i).("room"+j).physics,"underfloor")
                % Radiator only
                fullListRoomPhys(and(fullListRoomPhys(:,1)==i,fullListRoomPhys(:,2)==j),3) = 1;
                blkName = strcat(mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),strcat("/RoomRad_A",num2str(i),"R",num2str(j),"_",roomNameDisp));
                blkLibType = "Room with Radiator"; % ["Room","Room with Radiator","Room with UFP","Room with UFP & Radiator"]
                add_block(customBlkPath.roomRad,blkName,"Position",roomJvertNonRotated);
                mdlBlkPath.blkNameBldgPhys(i,j) = 1;
                mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2) = mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2)+1;
            else
                % Room with air volume only, no radiator or underfloor piping
                blkName = strcat(mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),strcat("/Room_A",num2str(i),"R",num2str(j),"_",roomNameDisp));
                blkLibType = "Room"; % ["Room","Room with Radiator","Room with UFP","Room with UFP & Radiator"]
                add_block(customBlkPath.roomOnly,blkName,"Position",roomJvertNonRotated);
                mdlBlkPath.blkNameBldgPhys(i,j) = 0;
            end
            mdlBlkPath.blkNameBldg(i,j) = blkName;
            mdlBlkPath.blkNameBldgLibType(i,j) = blkLibType;
            mdlBlkPath.blkNameBldgLoc(i,j) = num2str(roomJvertNonRotated);
        end

        msgDisplayCount = displayDiagnostics(ErrorMsg=strcat("Re-created building floor plan for level #",num2str(floorLevelNum)),ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

        % Create internal walls
        intWallVert = getInternalWallList(BuildingData=apartment3D,FloorNumber=floorLevelNum);
        numIntWalls = size(intWallVert,1);
        mdlBlkPath.blkNameIntWall = strings(numIntWalls,2);
        for i = 1:numIntWalls
            aptA = intWallVert(i,1);
            roomA = intWallVert(i,2); 
            aptB = intWallVert(i,3);
            roomB = intWallVert(i,4);
            solidFrac = intWallVert(i,5);
            if solidFrac < 0.99
                [fullPathWall,coordWallStr] = addInternalWallBetweenRooms(Apartment=apartment3D,...
                    BlockPath=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),WallType="Wall with Opening",...
                    BlockPathRoomA=mdlBlkPath.blkNameBldg(aptA,roomA),BlockPathRoomB=mdlBlkPath.blkNameBldg(aptB,roomB),...
                    RoomIndices=[aptA,roomA;aptB,roomB],ScaleToPlot=scaleToPlot,WallSubsystemDim=wallSubsystemDim);
            else
                [fullPathWall,coordWallStr] = addInternalWallBetweenRooms(Apartment=apartment3D,...
                    BlockPath=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),WallType="Solid Wall",...
                    BlockPathRoomA=mdlBlkPath.blkNameBldg(aptA,roomA),BlockPathRoomB=mdlBlkPath.blkNameBldg(aptB,roomB),...
                    RoomIndices=[aptA,roomA;aptB,roomB],ScaleToPlot=scaleToPlot,WallSubsystemDim=wallSubsystemDim);
            end
            mdlBlkPath.blkNameIntWall(i,1) = fullPathWall;
            mdlBlkPath.blkNameIntWall(i,2) = coordWallStr;
        end

        msgDisplayCount = displayDiagnostics(ErrorMsg=strcat("Re-created internal walls for level #",num2str(floorLevelNum)),ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
    
        extWallVert = apartment3D.("apartment1").("room1").geometry.dim.allExtWallVertices;
        numExtWalls = size(extWallVert,1);
        mdlBlkPath.blkNameExtWall = strings(numExtWalls,1);
        mdlBlkPath.blkNameExtWallLoc = zeros(numExtWalls,4);
    
        % Create external walls.
        for i = 1:numExtWalls
            [mdlBlkPath.blkNameExtWall(i,1),mdlBlkPath.blkNameExtWallLoc(i,:),connWall,aptn,room] = ...
                addExternalWall(BlockPath=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                BuildingData=apartment3D,FloorLevelNumber=floorLevelNum,IndexExtWallList=i,...
                ScaleToPlot=scaleToPlot,WallSubsystemDim=wallSubsystemDim);
    
            simscape.addConnection(mdlBlkPath.blkNameBldg(aptn,room),("W"+num2str(connWall)),mdlBlkPath.blkNameExtWall(i,1),"B","autorouting","on");
    
            labelName = strcat(mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),"/Amb",num2str(i));
            moveLblBy = 3;
            lblBaselineLoc = [mdlBlkPath.blkNameExtWallLoc(i,1)+wallSubsystemDim,mdlBlkPath.blkNameExtWallLoc(i,2)+wallSubsystemDim,mdlBlkPath.blkNameExtWallLoc(i,1)+2*wallSubsystemDim,mdlBlkPath.blkNameExtWallLoc(i,2)+2*wallSubsystemDim];
            if connWall == 2
                set_param(mdlBlkPath.blkNameExtWall(i,1),"Orientation","left");
                labelOrient = "right";
                labelLocation = lblBaselineLoc + moveLblBy*wallSubsystemDim*[1 0 1 0];
            elseif connWall == 3
                set_param(mdlBlkPath.blkNameExtWall(i,1),"Orientation","down");
                labelOrient = "up";
                labelLocation = lblBaselineLoc + moveLblBy*wallSubsystemDim*[0 -1 0 -1];
            elseif connWall == 1
                set_param(mdlBlkPath.blkNameExtWall(i,1),"Orientation","up");
                labelOrient = "down";
                labelLocation = lblBaselineLoc + moveLblBy*wallSubsystemDim*[0 1 0 1];
            else
                labelOrient = "left";
                labelLocation = lblBaselineLoc + moveLblBy*wallSubsystemDim*[-1 0 -1 0];
            end
            
            add_block(libBlkPath.labelConn,labelName,"Position",labelLocation);
            set_param(labelName,"Label","A");
            set_param(labelName,"Orientation",labelOrient);
            set_param(labelName,"ShowName","off");
            simscape.addConnection(mdlBlkPath.blkNameExtWall(i,1),"A",labelName,"port");
        end

        msgDisplayCount = displayDiagnostics(ErrorMsg=strcat("Re-created external walls for level #",num2str(floorLevelNum)),ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

        minX = 0;maxX = 0;
        for idx = 1:size(listofRooms,1)
            i = listofRooms(idx,1);
            j = listofRooms(idx,2);
            vecValues = str2num(mdlBlkPath.areaNameRoomLoc(i,j));
            % For some reason, str2double() does NOT work (gives NaN).
            minX = min(minX,vecValues(1,1));
            maxX = max(maxX,vecValues(1,1));
        end
   
        % Add Ambient thermal port.
        portAmbLoc = [minX-spacingFromMinX*spacingVal spacingVal minX-spacingFromMinX*spacingVal+sizeVal spacingVal+sizeVal];
        portA = addPortToCanvas(CanvasLocation=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                                PortName="Amb",PortSide="left",...
                                PortLocation=portAmbLoc);
        labelName = strcat(mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),"/AmbPort");
        add_block(libBlkPath.labelConn,labelName,"Position",[portAmbLoc(1,1),portAmbLoc(1,2),portAmbLoc(1,1)+labelSize,portAmbLoc(1,2)+labelSize]+[10*labelSize 0 10*labelSize 0]);
        set_param(labelName,"Label","A");
        set_param(labelName,"Orientation","right");
        set_param(labelName,"ShowName","off");
        simscape.addConnection(portA,"port",labelName,"port");
    
        % Add Solar input port. 
        portR = addPortToCanvas(CanvasLocation=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                                PortName="Solar",PortSide="left",...
                                PortLocation=[minX-spacingFromMinX*spacingVal 3*spacingVal minX-spacingFromMinX*spacingVal+sizeVal 3*spacingVal+sizeVal]);
        for i = 1:numExtWalls
            simscape.addConnection(mdlBlkPath.blkNameExtWall(i,1),"R",portR,"port","autorouting","on");
        end
    
        % Add output Temperature vector port, T.
        positionSubsystem = [maxX+(1+spacingFromMaxX)*spacingVal 0-2*spacingVal maxX+(1+spacingFromMaxX)*spacingVal+sizeVal nRooms(floorLevelNum,1)*10-2*spacingVal];
        outputPortTLoc = collateBuildingTemperatureData(CanvasPath=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
            ConnectToBlock=mdlBlkPath.blkNameBldg,ConnectToBlockPort="T",...
            SizeParameters=[spacingVal,wallSubsystemDim,sizeVal,sizeArrayNodeConn],...
            BaselineLocation=positionSubsystem,NumBlocksToConnect=size(listofRooms,1),...
            BlockIndices=listofRooms);
    
        if mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2) > 0
            msgDisplayCount = displayDiagnostics(ErrorMsg=strcat("Adding TL nodes for level #",num2str(floorLevelNum)),ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
            portV = addPortToCanvas(CanvasLocation=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                                             PortName="V",PortSide="left",...
                                             PortLocation=[minX-spacingFromMinX*spacingVal -spacingVal minX-spacingFromMinX*spacingVal+sizeVal -spacingVal+sizeVal]);
            locPortTLA = [minX-spacingFromMinX*spacingVal -spacingVal minX-spacingFromMinX*spacingVal+sizeVal -spacingVal+sizeVal]+[0 spacingVal 0 spacingVal];
            portTLA = addPortToCanvas(CanvasLocation=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                                             PortName="TL_A",PortSide="left",...
                                             PortLocation=locPortTLA);

            moveByDist = 2*[positionSubsystem(1,3)-positionSubsystem(1,1) 0 positionSubsystem(1,3)-positionSubsystem(1,1) 0];
            locPortTLB = [positionSubsystem(1,1) outputPortTLoc(1,2)+spacingVal positionSubsystem(1,3) outputPortTLoc(1,4)+spacingVal]+moveByDist;
            portTLB = addPortToCanvas(CanvasLocation=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                                             PortName="TL_B",PortSide="right",...
                                             PortLocation=locPortTLB);
            if mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2) > 1
                % If there are more than 1 room with TL connection, use Array
                % Connection block.
                blkNameArrayTLA = addArrayConnectionBlock(BlockPath=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                                                          BlockName="TL_in",Domain="foundation.thermal_liquid.thermal_liquid",...
                                                          NumberOfNodes=mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2),...
                                                          BlockLocation=locPortTLA+[5*wallSubsystemDim 0 6*wallSubsystemDim wallSubsystemDim*mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2)],...
                                                          Orientation="left",AddLabel=true,LabelName="TL_A");
                simscape.addConnection(blkNameArrayTLA,"arrayNode",portTLA,"port");
                blkNameArrayTLB = addArrayConnectionBlock(BlockPath=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                                                          BlockName="TL_out",Domain="foundation.thermal_liquid.thermal_liquid",...
                                                          NumberOfNodes=mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2),...
                                                          BlockLocation=locPortTLB-[6*wallSubsystemDim wallSubsystemDim*mdlBlkPath.nodesPerFloorLvl(floorLevelNum,2) 5*wallSubsystemDim 0],...
                                                          Orientation="right",AddLabel=true,LabelName="TL_B");
                simscape.addConnection(blkNameArrayTLB,"arrayNode",portTLB,"port");
            end
            
            connectTLdomainAtBldgLevel(PathData=mdlBlkPath,BlockIndices=listofRooms,FloorLevel=floorLevelNum);
    
        end
    
        % Add Heat Source port. Connect 'S' and 'V' (optional) ports to room
        % blocks.
        portS = addPortToCanvas(CanvasLocation=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),...
                                PortName="S",PortSide="left",...
                                PortLocation=[minX-spacingFromMinX*spacingVal -3*spacingVal minX-spacingFromMinX*spacingVal+sizeVal -3*spacingVal+sizeVal]);
        for idx = 1:size(listofRooms,1)
            i = listofRooms(idx,1);
            j = listofRooms(idx,2);
            simscape.addConnection(mdlBlkPath.blkNameBldg(i,j),"S",portS,"port","autorouting","on");
            % ****************************************************
            % IMP : CALCULATE INDEX OF INPUT DATA, indxS and indxV
            % ****************************************************
            indxNumSerial = fullListRoomPhys(and(fullListRoomPhys(:,1)==i,fullListRoomPhys(:,2)==j),4);
            % The 4th index stores the serial number of the data. See
            % iniPhysicsForAllRoomsBuilding().
            set_param(mdlBlkPath.blkNameBldg(i,j),"indxS",num2str(indxNumSerial));
            
            if mdlBlkPath.blkNameBldgPhys(i,j) == 1
                simscape.addConnection(mdlBlkPath.blkNameBldg(i,j),"V",portV,"port","autorouting","on");
                set_param(mdlBlkPath.blkNameBldg(i,j),"indxV",num2str(indxNumSerial));
            end
        end
    
        locArray = [positionSubsystem(1,1) -3*spacingVal positionSubsystem(1,3) -3*spacingVal+wallSubsystemDim*mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1)];
        
        % Add TOP port and array of connections for all floorplan definition.
        addPortAndArrayOfConnection(Domain="foundation.thermal.thermal",ArrayConnectionLocation=locArray,...
            BlockPath=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),PortName="Top",PortSide="right",...
            AddLabel=true,NumberNodes=mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1),...
            SizeParameters=[spacingVal,wallSubsystemDim,sizeVal],LabelSize=labelSize);
        addLabelToApartmentRoom(BuildingModel=apartment3D,FloorLevel=floorLevelNum,RoomPathData=mdlBlkPath,...
            RoomPortName="Top",Orientation="auto",LabelSize=labelSize);
        
        msgDisplayCount = displayDiagnostics(ErrorMsg=strcat("Add ports for Top/Bottom at level #",num2str(floorLevelNum)),ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

        % Add TOP port and array of connections for all floor/roof definition.
        blkNameArray = addPortAndArrayOfConnection(Domain="foundation.thermal.thermal",...
            ArrayConnectionLocation=locArray,BlockPath=mdlBlkPath.blkNameFloorConn(floorLevelNum+1,1),...
            PortName="Top",PortSide="right",AddLabel=false,...
            NumberNodes=mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1),SizeParameters=[spacingVal,wallSubsystemDim,sizeVal]);
        if floorLevelNum == 1
            blkNameArrayGrd = addPortAndArrayOfConnection(Domain="foundation.thermal.thermal",...
                ArrayConnectionLocation=locArray,BlockPath=mdlBlkPath.blkNameFloorConn(floorLevelNum,1),...
                PortName="Top",PortSide="right",AddLabel=false,...
                NumberNodes=mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1),SizeParameters=[spacingVal,wallSubsystemDim,sizeVal]);
        end
    
        % Add connections
        for idx = 1:size(listofRooms,1)
            i = listofRooms(idx,1);
            j = listofRooms(idx,2);
            if floorLevelNum == 1
                simscape.addConnection(mdlBlkPath.areaNameGround(i,j),"A",blkNameArrayGrd,strcat("elementNode",num2str(idx)));
            end
            simscape.addConnection(mdlBlkPath.areaNameRoof(i,j),"A",blkNameArray,strcat("elementNode",num2str(idx)));
        end
    
        % Add BOTTOM node port
        locArray = [positionSubsystem(1,1) 3*spacingVal positionSubsystem(1,3) 3*spacingVal+wallSubsystemDim*mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1)];
    
        % Add BOTTOM port and array of connections for all floorplan definition.
        addPortAndArrayOfConnection(Domain="foundation.thermal.thermal",ArrayConnectionLocation=locArray,...
            BlockPath=mdlBlkPath.blkNameFloorLevel(floorLevelNum,1),PortName="Bottom",PortSide="right",...
            AddLabel=true,NumberNodes=mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1),...
            SizeParameters=[spacingVal,wallSubsystemDim,sizeVal],LabelSize=labelSize);
        addLabelToApartmentRoom(BuildingModel=apartment3D,FloorLevel=floorLevelNum,RoomPathData=mdlBlkPath,...
            RoomPortName="Bottom",Orientation="auto",LabelSize=labelSize);
        
        % Add TOP port and array of connections for all floor/roof definition.
        blkNameArray = addPortAndArrayOfConnection(Domain="foundation.thermal.thermal",...
            ArrayConnectionLocation=locArray,BlockPath=mdlBlkPath.blkNameFloorConn(floorLevelNum+1,1),...
            PortName="Bottom",PortSide="right",AddLabel=false,...
            NumberNodes=mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1),SizeParameters=[spacingVal,wallSubsystemDim,sizeVal]);
        if floorLevelNum == 1
            blkNameArrayGrd = addPortAndArrayOfConnection(Domain="foundation.thermal.thermal",...
                ArrayConnectionLocation=locArray,BlockPath=mdlBlkPath.blkNameFloorConn(floorLevelNum,1),...
                PortName="Bottom",PortSide="right",AddLabel=false,...
                NumberNodes=mdlBlkPath.nodesPerFloorLvl(floorLevelNum,1),SizeParameters=[spacingVal,wallSubsystemDim,sizeVal]);
        end
    
        % Add connections
        for idx = 1:size(listofRooms,1)
            i = listofRooms(idx,1);
            j = listofRooms(idx,2);
            if floorLevelNum == 1
                simscape.addConnection(mdlBlkPath.areaNameGround(i,j),"B",blkNameArrayGrd,strcat("elementNode",num2str(idx)));
            end
            simscape.addConnection(mdlBlkPath.areaNameRoof(i,j),"B",blkNameArray,strcat("elementNode",num2str(idx)));
        end

        msgDisplayCount = displayDiagnostics(ErrorMsg=strcat("Completed all port connections at level #",num2str(floorLevelNum)),ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
        
        rangeIntWalls = ((floorLevelNum-1)*numIntWalls+1):(floorLevelNum*numIntWalls);
        mdlBlkPath.blkNameWallInternal(rangeIntWalls,1) = mdlBlkPath.blkNameIntWall(:,1);
        rangeExtWalls = ((floorLevelNum-1)*numExtWalls+1):(floorLevelNum*numExtWalls);
        mdlBlkPath.blkNameWallExternal(rangeExtWalls,1) = mdlBlkPath.blkNameExtWall(:,1);
        
    end
    
    if sum(mdlBlkPath.nodesPerFloorLvl(:,2)) > 0
        noTLnodesDefined = false;
    else
        noTLnodesDefined = true;
    end
    
    baselineLocationPorts = [[min(mdlBlkPath.levelSubsysLoc(:,1)),max(mdlBlkPath.levelSubsysLoc(:,2))], ...
                              sizeArrayNodeConn+[min(mdlBlkPath.levelSubsysLoc(:,1)),max(mdlBlkPath.levelSubsysLoc(:,2))]]...
                              -3*[sizeArrayNodeConn -(2/3)*sizeArrayNodeConn sizeArrayNodeConn -(2/3)*sizeArrayNodeConn];
    if ~noTLnodesDefined
        
        msgDisplayCount = displayDiagnostics(ErrorMsg="Adding TL nodes for building coolant/heating fluid supply",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

        mdlBlkPath.locArrayNodesInletBldg = baselineLocationPorts;
        mdlBlkPath.nameArrayNodesInletBldg = strcat(mdlBlkPath.libBuildingPath,"/TLinlet");
        add_block("built-in/Subsystem",mdlBlkPath.nameArrayNodesInletBldg,...
                  "Position",mdlBlkPath.locArrayNodesInletBldg);
        mdlBlkPath.locArrayNodesOutletBldg = [[max(mdlBlkPath.levelSubsysLoc(:,3)),max(mdlBlkPath.levelSubsysLoc(:,2))], ...
                                               sizeArrayNodeConn+[max(mdlBlkPath.levelSubsysLoc(:,3)),max(mdlBlkPath.levelSubsysLoc(:,2))]]...
                                               +2*[sizeArrayNodeConn sizeArrayNodeConn sizeArrayNodeConn sizeArrayNodeConn];
        mdlBlkPath.nameArrayNodesOutletBldg = strcat(mdlBlkPath.libBuildingPath,"/TLoutlet");
        add_block("built-in/Subsystem",mdlBlkPath.nameArrayNodesOutletBldg,...
                  "Position",mdlBlkPath.locArrayNodesOutletBldg);
    
        % Add pipe network at building inlet/outlet
        [mdlBlkPath.namePipeInletBldg,...
         mdlBlkPath.namePipeOutletBldg] = addAndConnectPipeNetworkIO(...
                                          SubsysPathList=mdlBlkPath,...
                                          TotalNumFloors=topFloorLevelNum,...
                                          SizeParameters=[spacingVal,wallSubsystemDim,sizeVal,sizeArrayNodeConn]);
        
        msgDisplayCount = displayDiagnostics(ErrorMsg="Added pipe network to supply coolant/heating fluid to building",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
    end
    
    % Add connection between floors, through wall elements
    connectLevelThroughFloors(ListOfFloors=mdlBlkPath.blkNameFloorConn(:,1),...
                              listofLevels=mdlBlkPath.blkNameFloorLevel(:,1));
    
    msgDisplayCount = displayDiagnostics(ErrorMsg="Connected all levels together through Top and Bottom ports",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

    % Connect ports Amb, Solar, V, and S with subsystems
    portRlocation = [baselineLocationPorts(1,1),baselineLocationPorts(1,2),...
                     baselineLocationPorts(1,1)+sizeVal,baselineLocationPorts(1,2)+sizeVal]...
                     -2*[sizeArrayNodeConn,(3/2)*sizeArrayNodeConn,...
                         sizeArrayNodeConn,(3/2)*sizeArrayNodeConn];
    portA = addPortToCanvas(CanvasLocation=mdlBlkPath.libBuildingPath,...
            PortName="Amb",PortSide="left",...
            PortLocation=portRlocation-[0,sizeArrayNodeConn,0,sizeArrayNodeConn]);
    portR = addPortToCanvas(CanvasLocation=mdlBlkPath.libBuildingPath,...
            PortName="Solar",PortSide="left",...
            PortLocation=portRlocation);
    portS = addPortToCanvas(CanvasLocation=mdlBlkPath.libBuildingPath,...
            PortName="S",PortSide="left",...
            PortLocation=portRlocation+2*[0,sizeArrayNodeConn,0,sizeArrayNodeConn]);
    if ~noTLnodesDefined
        portV = addPortToCanvas(CanvasLocation=mdlBlkPath.libBuildingPath,...
                PortName="V",PortSide="left",...
                PortLocation=portRlocation+[0,sizeArrayNodeConn,0,sizeArrayNodeConn]);
        portTLA = addPortToCanvas(CanvasLocation=mdlBlkPath.libBuildingPath,...
                  PortName="TL_A",PortSide="left",...
                  PortLocation=portRlocation+3*[0,sizeArrayNodeConn,0,sizeArrayNodeConn]);
        portTLB = addPortToCanvas(CanvasLocation=mdlBlkPath.libBuildingPath,...
                  PortName="TL_B",PortSide="right",...
                  PortLocation=portRlocation+3*[0,sizeArrayNodeConn,0,sizeArrayNodeConn]+6*[spacingVal,0,spacingVal,0]);
    end

    % % Roof and Ground ports for the Building
    positionRoof = get_param(mdlBlkPath.blkNameFloorConn(topFloorLevelNum+1,1),"Position") - [0 spacingVal 0 spacingVal];
    positionGround = get_param(mdlBlkPath.blkNameFloorConn(1,1),"Position") + [0 spacingVal 0 spacingVal];
    portRoofLoc = [positionRoof(1,1),positionRoof(1,2),positionRoof(1,1)+sizeVal,positionRoof(1,2)+sizeVal];
    portGrndLoc = [positionGround(1,1),positionGround(1,2),positionGround(1,1)+sizeVal,positionGround(1,2)+sizeVal];
    portRoof = addPortToCanvas(CanvasLocation=mdlBlkPath.libBuildingPath,...
               PortName="Rf",PortSide="left",...
               PortLocation=portRoofLoc);
    set_param(portRoof,"Orientation","down");
    portGrnd = addPortToCanvas(CanvasLocation=mdlBlkPath.libBuildingPath,...
               PortName="Gr",PortSide="left",...
               PortLocation=portGrndLoc);
    set_param(portGrnd,"Orientation","up");
    simscape.addConnection(mdlBlkPath.blkNameFloorConn(topFloorLevelNum+1,1),"Top",portRoof,"port","autorouting","off");
    simscape.addConnection(mdlBlkPath.blkNameFloorConn(1,1),"Bottom",portGrnd,"port","autorouting","off");


    msgDisplayCount = displayDiagnostics(ErrorMsg="Added all ports for the library",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);

    simscape.addConnection(mdlBlkPath.blkNameFloorConn(topFloorLevelNum+1,1),"Solar",portR,"port","autorouting","on");
    for i = 1:topFloorLevelNum
        simscape.addConnection(mdlBlkPath.blkNameFloorLevel(i,1),"Solar",portR,"port","autorouting","off");
        simscape.addConnection(mdlBlkPath.blkNameFloorLevel(i,1),"Amb",portA,"port","autorouting","off");
        if mdlBlkPath.nodesPerFloorLvl(i,2) > 0 && ~noTLnodesDefined
            simscape.addConnection(mdlBlkPath.blkNameFloorLevel(i,1),"V",portV,"port","autorouting","off");
        end
        simscape.addConnection(mdlBlkPath.blkNameFloorLevel(i,1),"S",portS,"port","autorouting","off");
    end
    if ~noTLnodesDefined
        simscape.addConnection(mdlBlkPath.nameArrayNodesInletBldg,"in",portTLA,"port");
        simscape.addConnection(mdlBlkPath.nameArrayNodesOutletBldg,"out",portTLB,"port");
        simscape.addConnection(mdlBlkPath.nameArrayNodesInletBldg,"Amb",portA,"port","autorouting","off");
        simscape.addConnection(mdlBlkPath.nameArrayNodesOutletBldg,"Amb",portA,"port","autorouting","off");
    end
    % simscape.addConnection(mdlBlkPath.blkNameFloorConn(topFloorLevelNum+1,1),"Top",portA,"port","autorouting","smart");
    
    
    collateBuildingTemperatureData(CanvasPath=mdlBlkPath.libBuildingPath,...
        ConnectToBlock=mdlBlkPath.blkNameFloorLevel,ConnectToBlockPort="T",...
        SizeParameters=[spacingVal,wallSubsystemDim,sizeVal,sizeArrayNodeConn],...
        BaselineLocation=portRlocation,NumBlocksToConnect=topFloorLevelNum,...
        BlockIndices=[(1:topFloorLevelNum)',ones(1,topFloorLevelNum)'],ConnectionOrder="reverse");

    displayDiagnostics(ErrorMsg="Collate temperature signals for all rooms of the building",ErrorMsgNum=msgDisplayCount,Diagnostics=NameValueArgs.Diagnostics);
    
    % Rotate ports for main library block and add icon.
    hndl = get_param(mdlBlkPath.libBuildingPath,"PortHandles");
    if ~noTLnodesDefined
        inletTL = hndl.LConn(end-2);
        outletTL = hndl.RConn(1);
        grdThermal = hndl.LConn(end);
        rfThermal = hndl.LConn(end-1);
        placeSubsystemPort(rfThermal,"Top");
        placeSubsystemPort(outletTL,"Bottom");
        placeSubsystemPort(grdThermal,"Bottom");
        placeSubsystemPort(inletTL,"Bottom");
    else
        grdThermal = hndl.LConn(end);
        rfThermal = hndl.LConn(end-1);
        placeSubsystemPort(rfThermal,"Top");
        placeSubsystemPort(grdThermal,"Bottom");
    end
    % -------------------------------------------------

    % Collate all roofs and ground block path and type data.
    % flrOpen is to account for duplex construction definition.
    flrOpen = apartment3D.apartment1.room1.geometry.dim.floorConnMat;
    count = 0;
    for i = 1:size(mdlBlkPath.areaNameRoof,1)
        for j = 1:size(mdlBlkPath.areaNameRoof,2)
            if mdlBlkPath.areaNameRoof(i,j) ~= ""
                count = count + 1;
            end
        end
    end
    for i = 1:size(mdlBlkPath.areaNameGround,1)
        for j = 1:size(mdlBlkPath.areaNameGround,2)
            if mdlBlkPath.areaNameGround(i,j) ~= ""
                count = count + 1;
            end
        end
    end
    mdlBlkPath.blkNameRoofsAndGround = strings(count,5); % Five columns = Path, Type, Frac, Apt ref, Room ref
    count = 0;
    for i = 1:size(mdlBlkPath.areaNameRoof,1)
        for j = 1:size(mdlBlkPath.areaNameRoof,2)
            if mdlBlkPath.areaNameRoof(i,j) ~= ""
                fracOpen = 0;
                count = count + 1;
                mdlBlkPath.blkNameRoofsAndGround(count,4) = num2str(i);
                mdlBlkPath.blkNameRoofsAndGround(count,5) = num2str(j);
                mdlBlkPath.blkNameRoofsAndGround(count,1) = mdlBlkPath.areaNameRoof(i,j);
                if i == size(mdlBlkPath.areaNameRoof,1)
                    mdlBlkPath.blkNameRoofsAndGround(count,2) = "WallSolar";
                else
                    dataRoom = flrOpen(and(flrOpen(:,1)==i,flrOpen(:,2)==j),:);
                    if ~isempty(dataRoom)
                        fracOpen = min(1,max(0,1-dataRoom(1,6))); % 6th element stores solid fraction for wall between floors.
                    end
                    if fracOpen == 0
                        mdlBlkPath.blkNameRoofsAndGround(count,2) = "Wall";
                    else
                        mdlBlkPath.blkNameRoofsAndGround(count,2) = "WallOpen";
                    end
                end
                mdlBlkPath.blkNameRoofsAndGround(count,3) = num2str(fracOpen);
            end
        end
    end
    for i = 1:size(mdlBlkPath.areaNameGround,1)
        for j = 1:size(mdlBlkPath.areaNameGround,2)
            if mdlBlkPath.areaNameGround(i,j) ~= ""
                count = count + 1;
                mdlBlkPath.blkNameRoofsAndGround(count,1) = mdlBlkPath.areaNameGround(i,j);
                mdlBlkPath.blkNameRoofsAndGround(count,2) = "Wall";
                mdlBlkPath.blkNameRoofsAndGround(count,3) = num2str(0);
                mdlBlkPath.blkNameRoofsAndGround(count,4) = num2str(i);
                mdlBlkPath.blkNameRoofsAndGround(count,5) = num2str(j);
            end
        end
    end

    mdlBlkPath.partFileBuilding = apartment3D;

    % Clean up struct before passing back.
    if NameValueArgs.OnlyBlockNameOutput
        % The fieldsToKeep must be char array as output of allfields() is
        % char array. Subsequent operations fail if fieldsToKeep is made
        % into a string instead of char array.
        fieldsToKeep = {'blkNameBldg', 'blkNameBldgLibType', 'blkNameWallInternal', 'blkNameWallExternal', 'partFileBuilding', 'blkNameRoofsAndGround', 'namePipeInletBldg', 'namePipeOutletBldg'};
        allFields = fieldnames(mdlBlkPath);
        fieldsToRemove = allFields(~ismember(allFields, fieldsToKeep));
        mdlBlkPath = rmfield(mdlBlkPath, fieldsToRemove);
    end
end