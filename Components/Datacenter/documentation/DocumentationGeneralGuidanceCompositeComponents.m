%[text] # General Guidance on Composite Component Usage
%[text:tableOfContents]{"heading":"**Table of Contents**"}
%[text] %[text:anchor:TMP_88bc] **Acronyms**
%[text] - PDU - Power Distribution Unit
%[text] - CDU - Coolant Distribution Unit in a liquid cooled data center \
%[text] ## Data Center / Assemblies
%[text:table]{"columnWidths":[204,543],"ignoreHeader":true}
%[text] | **`Block`** | **`General Guidance for Usage`** |
%[text] | --- | --- |
%[text] | [Air Cooled PDU Assembly](file:./DocumentationAirCooledPDUAssembly.html) | Use this block to design air cooled data centers. This composite block models **PDU Racks** with **Rack Air Cooling** block.  |
%[text] | [PDU + CDU Assembly (LUT)](file:./DocumentationPDUCDUAssemblyLUT.html) | Use this block to model liquid cooled data centers using typical supplier data sheets or limited test data for the PDU and CDU components. This is the preferred block for long duration analysis, any optimization analysis etc. |
%[text] | [PDU + CDU Assembly (TL)](file:./DocumentationPDUCDUAssemblyTL.html) | Use this block to model liquid cooled data center using individual component data sheets for the CDU (eg: pumps, heat exchanger). This is the preferred block when designing controls for the PDU + CDU assembly. |
%[text] | [PDU + CDU Assembly (TL-TL)](file:./DocumentationPDUCDUAssemblyTLTL.html) | Use this block when you plan to design a detailed cold plate for your liquid cooled data center application. This block combines **PDU Racks (TL)** with the **CDU (TL) Detailed** block from data center composite library. |
%[text:table]
%[text] ## Data Center / PDU
%[text:table]{"columnWidths":[204,543],"ignoreHeader":true}
%[text] | **`Block`** | **`General Guidance for Usage`** |
%[text] | --- | --- |
%[text] | [Cold Plate](file:./DocumentationColdPlate.html) | Use this block to model IT tray liquid cooling using cold plate. You will need this block if you model liquid cooled data centers with each IT tray modelled with separate set of parameters, either for the **IT Tray** or the **Cold Plate** composite component. |
%[text] | [Server Tray](file:./DocumentationServerTray.html) | Use this block to model an IT server tray. Use this component when your IT tray gpu/cpu utilization changes between different trays for the same set of racks of a PDU. |
%[text] | [Server Tray (TL)](file:./DocumentationServerTrayTL.html) | Similar as **Server Tray**; helps you customize **Cold Plate** per server tray, based on modelling needs. |
%[text] | [PDU Racks](file:./DocumentationPDURacks.html) | Use this component when all IT server trays in a PDU have the same gpu/cpu utilization. |
%[text] | [PDU Racks (TL)](file:./DocumentationPDURacksTL.html) | Same as **PDU Racks**, but with a TL node. |
%[text:table]
%[text] ## Data Center / CDU
%[text:table]{"columnWidths":[204,543],"ignoreHeader":true}
%[text] | **`Block`** | **`General Guidance for Usage`** |
%[text] | --- | --- |
%[text] | [Rack Air Cooling](file:./DocumentationRackAirCooling.html) | Use this component with **PDU Racks** to simulate air cooled PDU units. |
%[text] | [CDU (LUT)](file:./DocumentationCDULUT.html) | Use this block to simulate CDU for liquid cooling applications. Use this component when you have limited performance data for the CDU. It is well suited to be used with **PDU Racks** composite component, as in the **PDU + CDU Assembly (LUT)** block. |
%[text] | [CDU (TL)](file:./DocumentationCDUTL.html) | Use this block to simulate CDU for liquid cooling applications and when you want to model the TL domain on CDU heat exchanger external side, ie. the side that connects to other facilities components. The internal liquid cooling loop is exposed as a thermal node to connect to the **PDU Racks** block. |
%[text] | [CDU (TL) Detailed](file:./DocumentationCDUTLDetailed.html) | Use this block to simulate CDU for liquid cooling applications and when you want to model the TL domain on CDU heat exchanger external as well as internal coolant loops. This block can be used only with **PDU Racks (TL)** block. |
%[text:table]
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
