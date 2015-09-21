<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1434139902604" ID="ID_871622850" MODIFIED="1434353581818" TEXT="Send eDischarge summary to the GP">
<node CREATED="1434140069882" ID="ID_625974443" MODIFIED="1442574534055" POSITION="right" TEXT="Extract information from outputs generated by eDischarge system">
<node CREATED="1434140247912" ID="ID_1048565638" MODIFIED="1434140354469" TEXT="Parse eDischarge PDF document"/>
<node CREATED="1434140247912" ID="ID_158131988" MODIFIED="1434140357574" TEXT="Parse eDischarge Word document"/>
<node CREATED="1434140247912" ID="ID_335353688" MODIFIED="1434140360973" TEXT="Parse eDischarge Kettering document"/>
<node CREATED="1434140247912" ID="ID_1264623867" MODIFIED="1434140364136" TEXT="Parse arbirtary eDischarge document"/>
</node>
<node CREATED="1434140110709" ID="ID_1615044733" MODIFIED="1434140367870" POSITION="right" TEXT="Enrich information from eDischarge system if required">
<node CREATED="1434140385954" ID="ID_1030707436" MODIFIED="1434140397928" TEXT="Look-up patient demographics from PDS"/>
<node CREATED="1434140402270" ID="ID_935006531" MODIFIED="1434140416110" TEXT="Add information about the sending organisation/workgroup"/>
</node>
<node CREATED="1434140161252" ID="ID_1329227777" MODIFIED="1434140371026" POSITION="right" TEXT="Create a structured CDA document in-line with national standards"/>
<node CREATED="1434140204958" ID="ID_663204558" MODIFIED="1434140374967" POSITION="right" TEXT="Send the document to the patient&apos;s registered GP">
<node CREATED="1434140518456" ID="ID_1843068417" MODIFIED="1434140566155" TEXT="Find the patient&apos;s registered GP on PDS"/>
<node CREATED="1434140533000" ID="ID_489232526" MODIFIED="1434140550770" TEXT="Look-up full GP practice details on SDS"/>
<node CREATED="1434140593907" ID="ID_1454612171" MODIFIED="1434140610485" TEXT="Identify what transports the GP practice can receive documents on"/>
<node CREATED="1434140614146" ID="ID_1232400466" MODIFIED="1434140620251" TEXT="Send the document over the Spine"/>
<node CREATED="1434140614146" ID="ID_937130441" MODIFIED="1434140633775" TEXT="Send the document over ITK Web Services"/>
</node>
</node>
</map>
