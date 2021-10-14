##Code modified from: https://bitbucket.org/genomicepidemiology/fimtyper/src/master/

# Go to wanted location for fimtyper
mkdir -p ../tools
cd ../tools
# Clone and enter the fimtyper directory
#git clone https://bitbucket.org/genomicepidemiology/fimtyper.git
cd fimtyper

#Install database
#git clone https://bitbucket.org/genomicepidemiology/fimtyper_db.git database

# Check that all DB scripts work, and validate the database is correct
./UPDATE_DB database
./VALIDATE_DB database

#Install dependencies
bash brew.sh

#I needed to install the blast databases myself, the brew.sh script gave me an error:
curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/LATEST/ncbi-blast-2.12.0+-x64-linux.tar.gz > blast.tar.gz
tar -zxvf blast.tar.gz

