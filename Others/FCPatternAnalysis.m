%% TMS caused target-network connectivity pattern shifting

% load the symptom txt
load('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/YBChangesReal.txt')
load('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/YBChangesSham.txt')
load('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/YBRealPrePost.txt')
load('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/YBShamPrePost.txt')
load('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis_ExternalPrediction/Results/YBprepostTMS.txt')
%%
%  test whether pre-TMS state idea FC pattern sig correlate
%  Symptom improvement
% load the pre-TMS data in real group, individualized Seed FCP
preTMSrealFCP = 'preReal'
[dataall voxel head] = rest_to4d (preTMSrealFCP) ;  
nsubj = 18 ;   THRr = 0.14 ;  %THRr = 0.53 ;
% leave one out prediction
for i = 1 :  nsubj
    i
    YBC = YBChangesReal ;
    YBC (find(YBC==0)) = 0.000001 ;
    data2 = reshape(dataall,61*73*61,nsubj) ;  
    testdata = data2(:,i) ;  %test data
    
    YBC(i) = []  ;
    data2(:,i) = [];
    data4 = sum((data2.*repmat(YBC',61*73*61,1)),2)/sum(YBC) ; % get the weighted mean map
%     
    mdata1=mean(data2,2);
%     mdata1(find(abs(mdata1)<THRr))=0 ; 
%      mdata1=1 ;
%     rmap = TMSfastCorr(data2',YBC) ; % to get the correlation map
%     rmap(find(abs(rmap)<0.47))=0 ;
    rmap=1;
    [sparR(i,1) p] = corr(testdata(find(mdata1.*rmap)),data4(find(mdata1.*rmap))) ;
    clear b sparj data2 refdata rmap data1 YBC data1 p
end
[r p] = corr (atanh(sparR), YBChangesReal) 
lillietest(atanh(sparR))
[r p] = corr (atanh(sparR),YBChangesReal,'type','Spearman')
rest_WriteNiftiImage(reshape(rmap,61,73,61),head,'ccr.nii')
%% get the ideal FC pattern 
nsubj = 18 ; 
YBC=YBChangesReal;
YBC (find(YBC==0)) = 0.000001 ;
data2 = dataall ;
data2  =  reshape(data2,61*73*61,nsubj).*repmat(YBC',61*73*61,1) ;
refdata = sum(data2,2)/sum(YBC) ;
[datatemp voxel head] = rest_readfile ('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/roi/roi_Resliced/Resliced_GPe_L.nii') ; %GET THE HEAD
rest_WriteNiftiImage(reshape(refdata,61,73,61),head,'IdealHCPpreSham3.nii')
 
%% TEST RCT regression model for external real group data (n=11)
%load the YBprepostTMS.txt for prediction
load('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis_ExternalPrediction/Results/YBprepostTMS11.txt') ;

preTMSrealFCP = '/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/IndiSMAFC_FunImgARCcwgWFS2/preReal'
[dataall voxel head] = rest_to4d (preTMSrealFCP) ;  

% load the ideal FCP file
[FCPdata voxel head] = rest_readfile('idealHCPpreReal.nii')  ;

nsubj = 18 ;   THRr = 0.14 ;
for j = 1 : nsubj
    j
    YBC = YBChangesReal ; YBCj=YBC ;
    YBCj (find(YBCj==0)) = 0.000001 ;
    dataref = reshape(dataall,61*61*73,nsubj);
    datapool = dataref.*repmat(YBC',61*73*61,1)  ;
    dataj = dataref(:,j) ;
    datapool (:,j) = [] ; 
    YBCj (j) = []  ;
    
    refdataj = sum(datapool,2)/sum(YBCj) ;
%     dataref(find(abs(dataref)<THRr))=0;
    datamask = dataref;
    datamask(:,j)=[];
    datamask = mean(datamask,2) ; 
    datamask(find(abs(datamask)<THRr))=0 ;
    [sparj(j,1) p] = corr(dataj(find(datamask)),refdataj(find(datamask))) ;
end
     sparj = [ones(length(YBChangesReal),1),sparj] ;
     [b,bint,rsd,rint,stats] = regress (YBChangesReal,sparj)  
%%%%%%%%%%% regression model done !  %%%%%%%%%%%%%%%
  
%load the test data  'preTMS'  
  [testdata voxel head] = rest_to4d ('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/IndiSMAFC_FunImgARCcwgWFS2/preReal') ;  
  
  rmapj = reshape(dataall,61*61*73,nsubj);
%   rmapj = TMSfastCorr(rmapj',YBChangesReal) ; % to get the correlation map

  rmapj=sum(rmapj,2)/nsubj; rmapj(find(abs(rmapj)<THRr))=0; rmapj(isnan(rmapj))=0;
  rmapj(find(rmapj))=1; 
for i = 1 : size(testdata,4)
    tdata = testdata(:,:,:,i) ;
    tdata = reshape(tdata,61*73*61,1)  ;
    [sparExternal(i,1) p] = corr(FCPdata(find(reshape(FCPdata,61*73*61,1).*rmapj)),...
                                 tdata(find(reshape(FCPdata,61*73*61,1).*rmapj)) );
NewYBC2(i,1) = b(2)*sparExternal(i,1)+b(1) ;
end
[r p] = corr(atanh(sparExternal),YBprepostTMS)
[r p] = corr(atanh(NewYBC2),YBprepostTMS)



%% to explore the mechanism of rTMS by cross subject correlation
%  correlating pre- and post-TMS FCP to HC HCP, the more FCP changed
%  to HC, the more symptom impoved. 

[postdata voxel head] = rest_to4d ('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/IndiSMAFC_FunImgARCcwgWFS2/postReal') ; 
[predata voxel head] = rest_to4d ('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/IndiSMAFC_FunImgARCcwgWFS2/preReal') ; 
[hcdata voxel head] = rest_to4d ('/mnt/NCPL04/NKI2040/Results/RealROIIndiMeanFC') ; 
a=[1 3 6 8 10 12 13 14 16 17] % sym chg < 35%
b=[2 4 7 9 11 15 18]
hcdata(:,:,:,a)=[]; predata(:,:,:,a)=[]; postdata(:,:,:,a)=[];
thrr = 0.14  
for i =1 : size(hcdata,4)
    postdata1 = reshape(postdata(:,:,:,i),61*73*61,1) ;
    predata1 = reshape(predata(:,:,:,i),61*73*61,1) ;
    hcdata1 = reshape(hcdata(:,:,:,i),61*73*61,1) ;
mask1 = postdata1; mask1(find(mask1<thrr)) = 0;
mask2 = predata1; mask2(find(mask2<thrr)) = 0;
mask3 = hcdata1; mask3(find(mask3<thrr)) = 0;
mask = mask1.*mask2.*mask3 ;
mask=logical(mask);

    [rreal(i,1) p(i,1)] = corr(predata1(find(mask)),hcdata1(find(mask))) ;
     [rreal(i,2) p(i,2)] = corr(postdata1(find(mask)),hcdata1(find(mask))) ;
   [rreal(i,3),p(i,3)] = corr(postdata1(find(mask)),predata1(find(mask))) ;
end
    
 [r p] = corr(rreal(:,2)-rreal(:,1),YBChangesReal)  
 [rr p] = corr(rreal(:,1),YBChangesReal)  
 [rr p] = corr(rreal(:,2),YBChangesReal)  
  [rr p] = corr(rreal(:,3),YBChangesReal)  
[h pp ci t] =ttest(rreal(:,2)-rreal(:,1))  
 
 rest_WriteNiftiImage([reshape(predata1.*mask,61,73,61)],head,'preRealSubj12.nii')
  rest_WriteNiftiImage([reshape(postdata1.*mask,61,73,61)],head,'postRealSubj12.nii')
  rest_WriteNiftiImage([reshape(hcdata1.*mask,61,73,61)],head,'hcRealSubj12.nii')

  
 %% group level: consider the postive or negative regions as a whole, respectively
preT = 'preReal.nii'
prepath  = 'preReal'
postpath  = 'postReal';
[data1 voxel head] = rest_to4d (prepath) ;  
[data2 voxel head] = rest_to4d (postpath) ;  
[predata voxel head] = rest_ReadFile (preT) ;  
tthr = 4 ;  % p=0.05
tthr = 5.5 ;  % p=0.0001 N=14
tthr = 5.04 ;  % p=0.0001 N=18

    mdata=reshape(predata,61*73*61,1) ; 
    mdatap =mdata; mdatan=mdata;
    mdatap(find(mdatap<tthr))=0;mdatan(find(mdatan>(tthr*(-1))))=0;
    mdatap(find(mdatap))=1;  mdatan(find(mdatan))=1;

for i =1 : size(data1,4)
    data11 = reshape(data1(:,:,:,i),61*73*61,1) ; 
    data11p=data11.*mdatap; data11n=data11.*mdatan;
    a(i,1) = mean(data11p(find(data11p)),1) ;
    a(i,2) = mean(data11n(find(data11n)),1) ;
    
    data22 = reshape(data2(:,:,:,i),61*73*61,1) ; 
    data22p=data22.*mdatap; data22n=data22.*mdatan;
    a(i,3) = mean(data22p(find(data22p)),1) ;
    a(i,4) = mean(data22n(find(data22n)),1) ;
end
[h p ci t]=ttest(a(:,3:4)-a(:,1:2)) 


%% individulized: consider the postive or negative regions as a whole, respectively
prepath  = uigetdir %'R1'
postpath  = uigetdir %'R2-R1';
[data1 voxel head] = rest_to4d (prepath) ;  
[data2 voxel head] = rest_to4d (postpath) ;  
ssize = 21;
tthr = 0.26 ;   % p=0.0001 N=212

    mdata=reshape(data1,61*73*61,ssize) ; 
    mdatap =mdata; mdatan=mdata;
    mdatap(find(mdatap<tthr))=0; 
    mdatan(find(mdatan>(tthr*(-1))))=0;
    mdatap(find(mdatap))=1;  
    mdatan(find(mdatan))=1;

    data2 = reshape(data2,61*73*61,ssize) ; 
    data2p=data2.*mdatap; 
    data2n=data2.*mdatan;
    for i = 1 : ssize
        data2pp = data2p(:,i) ;
    a(i,1) = sum(data2pp,1)/size((find(data2pp)),1) ;
    data2nn=data2n(:,i); 
    a(i,2) = mean(data2nn(find(data2nn)),1) ;
    end
[h p ci t]=ttest(a) 












[theObjMask, theObjNum]=bwlabeln(mdatap,4); %DONG Zhang-Ye and YAN Chao-Gan 090711, make the Cluster Connectivity Criterion flexible.	%[theObjMask, theObjNum]=bwlabeln(Result);
	for x=1:theObjNum,
		theCurrentCluster = theObjMask==x;
		if length(find(theCurrentCluster))<10,
			mdatap(logical(theCurrentCluster))=0; %YAN Chao-Gan 081223, Original "Result(~logical(theCurrentCluster))=0;" was an error			
		end
    end

[data1 voxel thead] = rest_readfile('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/VA_FC_FunImgARCcwgWSF/sYeo2011_VANetworks.nii')  ;
[data2 voxel thead] = rest_readfile('preRealClust0001Posi.nii')  ;
data1(find(data1))=1; data2(find(data2))=1;
2*size(find(data1.*data2),1)/size(find(data1+data2),1)

[data1 voxel thead] = rest_readfile('/home/NCPL04/Desktop/OCD_data/rTMS_analysis/FMRIAnalysis/Results/VA_FC_FunImgARCcwgWSF/sYeo2011_DMNetworks.nii')  ;
[data2 voxel thead] = rest_readfile('preRealClust0001Nega.nii')  ;
data1(find(data1))=1; data2(find(data2))=1;
2*size(find(data1.*data2),1)/size(find(data1+data2),1)




rest_WriteNiftiImage(reshape(ddata1p ,61,73,61),thead,'cc1.nii')
rest_WriteNiftiImage(reshape(mdatap,61,73,61),thead,'cc.nii')

    
 
 
