clear
close all
clc
level = 1;
affichage = 0;
%% Chargement du fichier contenant le signal reçu
load 'signal_recu.mat';
if level > 1
 signal_recu = signal_recu(1:5:end);
end
% Enlever les parties inutiles
debut = 1;
while (abs(signal_recu(debut)) < 0.05)
 debut = debut + 1;
end
% Trouver la fin du signal 
fin = length(signal_recu);
while (abs(signal_recu(fin)) < 0.05)
 fin = fin - 1;
end
signal_recu = signal_recu(debut:fin);
% figure,
% plot(real(signal_recu));
% title('Signal recu');
% xlabel('Temps (s)');
% ylabel('Amplitude');
% grid on;
%% FILTRAGE ADAPTE
% Petite partie du signal
%signal_recu = signal_recu(1e5:1e5+1e4);
% Calcul du périodogramme de Welch
[DSP, f] = pwelch(signal_recu, 1024, 128, 2048, 1, 'centered');
% Calcul du filtre en racide de cos
Fse = 10;
rolloff = 0.5;
SPAN = round(5/rolloff); %0.2;
h_est = rcosdesign(rolloff, SPAN, Fse);
% Calcul de la DSP du filtre en racine de cos
DSP_h = abs(fft(h_est,2048)).^2/100;
if affichage == 0
 figure;
 plot(f, 10*log10(DSP));
 hold on;
 plot(f, 10*log10(fftshift(DSP_h)));
 xlabel('Fréquence (Hz)');
 ylabel('Amplitude');
 legend('DSP du signal','DSP du filtre en racine de cosinus surélevé')
 title('Superposition des DSP');
 grid on;
end
% Calcul du filtre de réception
filtre_adapte = flip(conj(h_est));
signal_h = conv(signal_recu, filtre_adapte);
% figure;
% plot(signal_h);
% title("Signal en sortie du filtre de réception");
% grid on;
% xlabel('Réel');
% ylabel('Imaginaire');
%% CALCUL DES DECALAGES
% Calcul du décalage temporelle (on suppose d'abord que le décalage en
% fréquence est négligeable)
L = floor(length(signal_h) / Fse);
test = 1;
if test == 0
 % TEST
 figure;
 for d = 1:Fse
 % Echantillonage à Ts
 signal_h_ech = zeros(1, L);
 for i = 1:L
 signal_h_ech(i) = signal_h(Fse*(i-1)+ d);
 end
 
 % Affichage
 subplot(2, 5, d);
 plot(signal_h_ech, '.');
 title(['Décalage d = ', num2str(d - 1)]);
 sgtitle("Signal après synchronisation temporelle");
 xlabel('Échantillons');
 ylabel('Amplitude');
 end
else
 % Synchronisation temporelle choisie
 signal_h_ech = zeros(1, L);
 decalage = 7; % Choix du décalage
 
 % Echantillonage à Ts
 for i = 1:L
 signal_h_ech(i) = signal_h(Fse*(i-1)+ decalage);
 end
 
 % Affichage
 if affichage == 0
 figure;
 subplot(1,2,1)
 plot(signal_h_ech);
 xlabel('Échantillons');
 ylabel('Amplitude');
 title("Après synchronisation temporelle");
 grid on;
 
 subplot(1,2,2)
 plot(signal_h_ech, '.');
 xlabel('Échantillons');
 ylabel('Amplitude');
 title("Après synchronisation temporelle");
 grid on;
 end
end
% Synchronisation fréquentielle
M = 4;
rk = signal_h_ech.^M;
delta = zeros(1, L);
phi = zeros(1, L);
alpha = 1;
beta = 0.1;
% Calcul de la phase
delta(1) = 0 + beta * imag(rk(1) * exp(-1j * phi(1)));
phi(1) = 0 + alpha * imag(rk(1) * exp(-1j * 0));
for k = 2:L
 delta(k) = delta(k-1) + beta * imag(rk(k) * exp(-1i * phi(k-1)));
 phi(k) = phi(k-1) + delta(k) + alpha * imag(rk(k) * exp(-1i * phi(k-1)));
end
% Synchronisation de la phase
signal_synchro = exp(-1i * phi/M) .* signal_h_ech;
% Tracer la phase en fonction du temps
N = length(signal_synchro);
t = (0:N-1) / Fse; % Temps associé à chaque échantillon
if affichage == 0
 figure;
 plot(phi);
 xlabel('Temps (s)');
 ylabel('Phase (radian)');
 title('Phase du signal en fonction du temps');
 grid on;
 figure;
 plot(real(signal_synchro), imag(signal_synchro), '.');
 title('Après synchronisation fréquentielle');
 xlabel('Réel'); 
 ylabel('Imaginaire');
 grid on;
end
%% Récepteur

% Démodulation QPSK
c = [-1, -1i, 1i, 1];
hatB = [];
for k = 1:length(signal_synchro)
 symbole = signal_synchro(k);
 
 % Calcule les distances
 d = zeros(1, 4);
 for i = 1:4
 d(i) = abs(symbole - c(i));
 end
 % Trouve l'indice du symbole le plus proche
 [~, idx] = min(d);
 % Associer les bits selon les indices trouvés
 if idx == 1 
 bits = [0 0];
 elseif idx == 2
 bits = [1 0];
 elseif idx == 3
 bits = [0 1];
 else
 bits = [1 1];
 end
 hatB = [hatB, bits];
end
% Convertir en vecteur colonne
hatB = hatB.';
% hatB doit être une matrice de log2(M) lignes et Ns
% calculé grace à la fonction de2bi(foo,2) foo étant ici une représentation entière des étiquettes
%% Décodage de source
T = 128; % taille de l'image
nb_bits = T*T*8;
offset = 10;
hatB = hatB(1+offset:nb_bits+offset); % On enlève les bits restants
hatMatBitImg = reshape(hatB(:),[],8);
matImg = bi2de(hatMatBitImg);
Img = reshape(matImg,T,T);
%% Affichage
figure
imagesc(Img)
colormap gray