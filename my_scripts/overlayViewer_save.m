function overlayViewer_save(V,maskV,probV,string,transp,maskC)
% V - grayscale image/volume
% maskV - volume where to overlay prob (indicate by 1)
% probV - probability you want to overlay
% trasp - transparency of overlay (default = 1)
% maskC - ground truth mask
% - Rakesh 02/03/15, edit 1 - 03/10/15
% edit 2 6/14/21 michael sobota
%shows only cases for which there is a lesion 
%edit 3: 7/6/21 edited to only show one image of the current volume, to be used
%in a loop so features can be viewed one by one 


if nargin < 5
    transp = 1;
end
cmap = colormap('jet');
numColors = size(cmap,1);

warning off;


existLesion = reshape(sum(sum(maskC,1),2),[],1);



        temp_ = find(existLesion>0);
        p = ceil(mean(temp_));
        I = V(:,:,p);
        mask = maskV(:,:,p);
        prob = probV(:,:,p);
        indImg = round(prob*numColors);
        rgbImg = ind2rgb(indImg,cmap);
        I = double(I);
        I = I/max(I(:));
        mask = double(mask);
        
       % if nargin > 4
       %     subplot(1,2,1);
       %     imshow(I);
        %    hold on;
       %     h = imshow(rgbImg);
        %    set(h,'AlphaData',transp*mask)
         %   save_fig = subplot(1,2,2);
            rgbImg2 = rgbImg.*maskV(:,:,p);
            imshow(rgbImg2);
            hold on;
            edgeC = edge(maskC(:,:,p),'canny');
            h1 = imshow(edgeC);   
            set(h1,'AlphaData',transp*edgeC);
            %edited to include heatmap in the second subplot image, and to
            %save the individual image from subplot
          %  hfig = figure;
         %   new_ = copyobj(save_fig, hfig);
         %   set(new_, 'Position', get(0, 'DefaultAxesPosition'));
            print('-r300', [string '.png'],'-dpng')
            close all;
                    
      %  else
         %   imshow(I);
         %   hold on;
         %   h = imshow(rgbImg);
         %   set(h,'AlphaData',transp*mask)
         %   save_fig = imshow(rgbImg);
         %   hfig = figure;
         %   new_ = copyobj(save_fig, hfig);
         %   set(new_, 'Position', get(0, 'DefaultAxesPosition'));
         %   print('-r300', ['/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/temp/' string '.png'],'-dpng')
            
                    
       % end
        
        % x = input(['save feature: ' string '? 1=YES/0=NO ']);
       % if x==1
         %   print('-r300',['feat_' string '_' num2str(p) '.png'],'-dpng');
        % end
    end
