scriptencoding utf-8
" TinySegmenterMakerを使って、
" 京大NTTブログコーパス<http://nlp.ist.i.kyoto-u.ac.jp/kuntt/#ga739fe2>
" から文節区切りを学習させたもの。

let tinysegmenter#knbc_bunsetu = {'BC1':{'AO':-334,'KH':-598},'BC2':{'AA':-5932,'HH':-215,'HN':4096,'IA':1701,'II':-3904,'IM':390,'IN':644,'IO':-1744,'KK':-12390,'NN':-180,'ON':-1453},'BC3':{'HH':933,'HI':2108,'HO':768,'IH':-3250,'II':3899,'OH':88},'BIAS':-12785,'BP1':{},'BP2':{'OB':-181,'OO':3904},'BQ1':{'BMH':1068,'BNH':251,'OHH':-742,'OOH':1896},'BQ2':{'BIH':-1529,'BII':-839,'OHH':-2658,'OIH':707,'OIO':-2020,'UIH':-427},'BQ3':{'OAO':-678,'OHH':46,'OHI':2564,'OII':942,'OIO':992,'OKI':250,'ONH':375},'BQ4':{'BHI':-464,'OIA':1810,'OIH':6821,'OIK':1646,'OIM':469,'OIN':945,'OOH':1830,'OOK':126,'OON':-909},'BW1':{'B1と':1058,'B1・':4249,'い、':-1809,'いう':1153,'いで':-181,'いも':-488,'い程':1063,'うな':1975,'うに':-967,'かし':2474,'かも':-5609,'から':4216,'こと':-1959,'この':-178,'しい':1671,'しか':247,'その':-1250,'たに':-492,'たら':2438,'った':661,'てい':-1279,'では':-4011,'とか':1743,'とが':-6989,'とは':-1021,'とも':-3644,'ない':1538,'のに':-238,'の間':300,'もう':1366,'もの':-366,'より':2921,'りゃ':1847,'るの':-694,'れて':-1531,'んと':-1200,'んな':1076,'少し':673,'思い':-1151,'最近':3880},'BW2':{'、と':-1806,'いも':2384,'くな':-2295,'たい':-1061,'てい':-2511,'てお':-8158,'て行':-3171,'であ':-8428,'でき':-2035,'でし':-1736,'です':-5657,'とい':4000,'とし':2773,'ない':-6469,'には':-2104,'のよ':-636,'はな':-325,'りし':242,'帯電':-764},'BW3':{'いい':3749,'いう':2813,'かか':482,'かけ':6188,'かっ':-2259,'から':-4387,'こと':2287,'この':4577,'さん':-670,'した':881,'して':1117,'すぐ':2780,'すご':119,'そう':-495,'その':7325,'それ':342,'ため':5594,'ちょ':5890,'でき':1901,'とい':-7931,'とき':6751,'とこ':7764,'とて':677,'どう':858,'ない':341,'なか':60,'なっ':-2278,'なる':335,'もう':802,'もの':14494,'よう':-4993,'よく':1422,'わか':1731,'出来':-5279,'祭り':554},'TC1':{'HHH':-361,'HIH':-454,'IHI':-1825,'IOI':-1319,'OOH':-425},'TC2':{'HII':-413,'IHI':-2181,'IIH':-400,'III':-1253,'IIN':188,'IIO':-317,'OHH':-959,'OII':-119},'TC3':{'HHH':-952,'IHI':-2683,'III':977,'IKK':2904,'IMH':917,'KHI':3324,'KII':1334},'TC4':{'HHH':-399,'HIH':135,'HIO':217,'HOO':634,'IHI':-575,'III':900,'IIO':-138,'IKI':1643,'IKK':-1700,'KKK':3158,'OII':-121},'TQ1':{'BIHI':672,'BIII':63,'OHHH':-488,'OHHI':789,'OIHI':-748,'OIII':-562,'UOHH':134},'TQ2':{'BHHI':-433,'BHIH':-1620,'BIII':-611,'OHII':-817,'OHOH':-1318,'OIIH':-500,'OIII':-1291,'OIIK':-1424,'OIIO':-407,'OIOI':-552},'TQ3':{'BIIH':1766,'OHII':-507,'OIII':64,'OINH':116,'OIOH':900,'OKKI':87,'OOHH':380,'OOHI':-1159},'TQ4':{'OHHH':57,'OHIH':-965,'OIIN':369,'OIOH':3375,'OKIH':245,'OOHH':-3455},'TW1':{'B2B1と':732,'B2B1・':4017,'という':1846,'ない程':533,'ような':179},'TW2':{'ではな':-3701,'気に入':-8864},'TW3':{'、そし':-3972,'ている':-4347,'てしま':-1957,'である':-2251,'という':2482,'と同時':-4365,'と言っ':-5267,'らない':-363,'帯電話':-885},'TW4':{'あるい':-6969,'かなり':3117,'くらい':4505,'こと。':564,'ことが':-2071,'ことに':-1156,'ところ':1503,'とても':374,'ない。':123,'なんて':-488},'UC1':{'A':-1196,'H':115,'I':220},'UC2':{'A':-685,'I':62},'UC3':{'A':-1125,'H':2011,'K':-1631,'N':-1586,'O':3988},'UC4':{'I':-6973,'M':2576,'N':2712,'O':-4426},'UC5':{'A':-641,'H':547,'O':-6662},'UC6':{'H':-563,'I':-284,'K':-1018,'N':1398,'O':-1277},'UP1':{'B':-45,'U':181},'UP2':{'O':-1751},'UP3':{'B':-1000,'O':3436},'UQ1':{'BH':-399,'OI':-100,'OK':468,'UI':1625},'UQ2':{'OH':-582,'OK':534,'OO':124},'UQ3':{'BH':237,'OH':513,'OI':6835,'OK':637,'ON':-5987},'UW1':{'B1':338,'、':336,'「':-121,'い':-473,'お':-596,'そ':1218,'っ':128,'て':61,'で':-512,'と':486,'な':-1190,'に':-850,'も':69,'や':-1040,'ん':200,'外':550},'UW2':{'お':-1629,'き':406,'く':-632,'け':123,'こ':-404,'さ':1739,'し':153,'そ':-1159,'た':-929,'っ':136,'て':-1321,'で':-347,'と':-573,'の':1670,'は':61,'ひ':-422,'ま':2271,'も':-123,'や':-184,'よ':1129,'る':-1498,'ん':488,'一':3388,'京':-1077,'人':339,'以':490,'全':1548,'多':380,'少':2932,'思':-438,'我':-3545,'最':1176,'毎':4230,'結':5184,'関':366},'UW3':{'、':13181,'々':2349,'「':-1949,'い':544,'う':2691,'か':2429,'が':10531,'き':-2931,'く':3966,'け':-1504,'こ':-1010,'さ':-1957,'し':-4113,'た':2685,'だ':-258,'ち':-4573,'っ':-9829,'て':2250,'で':3454,'と':5209,'ど':1279,'な':988,'に':8032,'の':5991,'は':10209,'ば':2375,'べ':-4084,'ま':-4916,'み':-3311,'も':6789,'や':1643,'よ':-1029,'ら':1270,'り':-1339,'る':3878,'れ':-4094,'わ':-366,'を':14825,'ん':-1217,'ラ':1300,'ー':2199,'中':4117,'京':-943,'人':3999,'今':6577,'光':-1245,'分':1789,'変':306,'度':2211,'後':4472,'日':2992,'昔':3202,'然':1544,'皆':2178,'真':240,'程':1454,'間':4264,'電':-621,'，':6780,'［':-3406,'］':3753},'UW4':{'■':815,'、':-20799,'。':-3859,'「':14865,'」':-375,'『':3414,'あ':6126,'い':1716,'お':15269,'か':-552,'が':-3699,'く':-1151,'け':-4759,'こ':7424,'ご':5440,'す':2135,'そ':4752,'だ':-3120,'っ':-8047,'つ':3430,'て':-7367,'で':-4597,'と':-309,'ど':2467,'に':-6652,'の':-4907,'は':-3182,'ひ':7230,'ほ':5720,'ま':970,'み':484,'も':-1265,'や':3013,'よ':1609,'ら':-8300,'り':-4323,'る':-9190,'れ':-7657,'ろ':-2878,'わ':1729,'を':-5564,'ん':-3383,'コ':787,'・':-239,'ー':-4619,'二':1033,'使':1810,'出':-409,'前':-2987,'合':-488,'後':-634,'思':2706,'放':-119,'物':-244,'私':2308,'込':-1669,'返':-683,'通':-1518,'間':-3165,'電':-1955,'（':494,'，':-5663},'UW5':{'E1':-2804,'あ':-3450,'い':380,'う':1187,'え':755,'が':-3573,'き':3232,'く':2062,'け':-249,'こ':597,'ご':918,'さ':-548,'し':-2238,'す':-3702,'ず':562,'せ':-470,'そ':-1646,'た':-489,'だ':-1187,'ち':918,'っ':3631,'つ':2889,'て':297,'で':-5288,'と':-2630,'な':-3360,'に':-3450,'の':-3290,'は':-3790,'べ':3418,'め':1451,'も':-2499,'よ':-735,'る':259,'れ':1519,'を':-3200,'ん':3117,'年':512,'料':1936},'UW6':{'E2':-3505,'、':569,'。':-490,'う':-1849,'え':-373,'ず':-246,'た':-1284,'だ':-473,'っ':704,'て':-839,'と':-357,'に':231,'の':-664,'は':-493,'め':627,'も':-310,'や':333,'ら':-184,'り':1225,'る':-136,'わ':398,'を':285,'ん':788,'ー':-697,'：':2708}}

let tinysegmenter#knbc_bunsetu['segment'] = function('tinysegmenter#func#segment')
