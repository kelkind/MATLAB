
clear
clc

%headers
disp('\% Class, Professor Name, Class Section, Due Date')
disp('\% Student A')
disp('\% Student B')
disp('\% Student C')
dateZ = strcat('\% DATE:  ',date);
disp(dateZ)

%open and read from file
myfile = input('Which design would you like to evaluate?  ','s');
fid = fopen(myfile,'r'); %this opens the file of your choosing
while fid<=0
    disp('File open not successful.')
    myfile = input('Which design would you like to evaluate? ','s');
    fid = fopen(myfile,'r'); 
end
input = '';
count = 0;
while feof(fid) == 0
	aline = fgetl(fid);
	count = count+1;
	if count>5 %data starts after line 5
        	input = strcat(input,aline);
	end
end

eval(input); %reads in concat string as matlab code
fclose(fid);

%dimensions from matrix C
[joints, members] = size(C);

%the vector in the ith column of matrix is the joints that each member is
%connected to
joint_con = zeros(2, members);
for i = 1:members
	joint_con(:,i) = find(C(:,i));
end;

%create the matrix A from dimensions of C
A = zeros(joints,members);
A = [A Sx; A Sy];
%matrix of straw lengths
straw_len = 0;
S = zeros(1,members);

for i = 1:members
	var = [X(joint_con(1,i)) Y(joint_con(1,i)); X(joint_con(2,i)) Y(joint_con(2,i))];
	distance = pdist(var);
	straw_len = straw_len + distance;
	S(i) = distance;

	A(joint_con(1,i),i) = (X(joint_con(2,i))-X(joint_con(1,i)))/distance;
	A(joint_con(2,i),i) = (X(joint_con(1,i))-X(joint_con(2,i)))/distance;

	A(joint_con(1,i)+joints,i) = (Y(joint_con(2,i))-Y(joint_con(1,i)))/distance;
	A(joint_con(2,i)+joints,i) = (Y(joint_con(1,i))-Y(joint_con(2,i)))/distance;
end;

L = L';
T = A\L; %solves for forces

fprintf('\nLoad: %0.3f N\n', max(L))
fprintf('Member forces (Newtons):\n')
for i = 1:members
 if T(i)<0 %Negative values means members in Compression
	fprintf('m%d: %.3f (C)\n',i,abs(T(i)))
 elseif T(i)>0 %Positive values mean members in Tension
	fprintf('m%d: %.3f (T)\n',i,T(i))
 elseif T(i)==0
	fprintf('m%d: %.3f (-)\n',i,T(i))
 end
end

fprintf('\nReaction forces (Newtons):\n')

fprintf('Sx1: %.3f\n',T(members +1))
fprintf('Sy1: %.3f\n',T(members +2))
fprintf('Sy2: %.3f\n',T(members +3))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
index = find(L~=0);
L(index)=1; %replace load with 1N
K = A\L; %K will be a vector in terms of L
forces=zeros(1,members);

for i=1:members
 if K(i)<0 %only for compressed members
	forces(i) = 432.109*(S(i))^(-1.506);
 end
end

loads=zeros(1,members);

for i=1:members
	if forces(i)>0 %if compressed member
    	loads(i)=abs(forces(i)/(K(i))); %calculates the load in which member
%i buckles
	end
end

maxLoad=min(loads(loads>0)); %finds the smallest load
brokenMember=find(loads==maxLoad);
fprintf('\nMember that breaks first: %d', brokenMember(1))
fprintf('\nLength of member that breaks first: %.3f cm', S(brokenMember(1)))
fprintf('\nMax load design can handle: %.3f N \n', maxLoad)
cost = 10*joints + 1*straw_len;
fprintf('Cost of truss: $%.2f%d\n', cost)
fprintf('\nTheoretical max load/cost ratio (N/$): %.4f\n', maxLoad/cost)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if cost>345
	fprintf('\nThis design is too costly.')
end
if maxLoad<4.91
	fprintf('\nThis design will not support the minimum weight for this project.')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L(index)=maxLoad;
G = A\L;
forces=zeros(1,members);
uncertainty=zeros(1,members);

%Calculates the forces in the members at maxLoad
fprintf('\nAt max load, %.3f N, the members forces (Newtons) are:\n', maxLoad)
for m=1:members
 if G(m)<0 %Negative values means members in Compression
	fprintf('m%d: %.3f (C)\n',m,abs(G(m)))
 elseif G(m)>0 %Positive values mean members in Tension
	fprintf('m%d: %.3f (T)\n',m,abs(G(m)))
 elseif G(m)==0
	fprintf('m%d: %.3f (-)\n',m,abs(G(m)))
 end

  if G(m)<0 %In compression
	%Buckling force determined by class data
	forces(m) = 432.109*(S(m))^(-1.506);
	uncertainty(m) = 289*(S(m))^(-2.5061);
  end
end
fprintf('\nThe buckling forces for the compressed members (Newtons) are:\n')
for i=1:members
	if forces(i)>0
    	fprintf('m%d: %0.3f\n', i, forces(i))
	end
end
fprintf('The uncertainty for the compressed members (Newtons) are:\n')
for i=1:members
	if uncertainty(i)>0
    	fprintf('m%d: %0.3f\n', i, uncertainty(i))
	end
end