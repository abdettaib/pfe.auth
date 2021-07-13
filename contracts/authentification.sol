pragma experimental ABIEncoderV2;
pragma solidity ^0.5.15;

contract authentification{
    
    //*****************************************************************************partie declarative ******************************************************************************************/
  
    //*****le possesseur du contrat*******//
  
  address public owner = msg.sender;
  
  
  
     //******reponse event *****************// 
     
  event retour(

     uint indexed date,
     string value);
  
  
  
  
     //**** association de chaque adress les application auquelles elle a le droit****//
     
  mapping(address => string[]) private droits;
  
  
  
  
  
     //*******liste globale des utilisateurs qui sont ajoutés********//
     
  address[] private utilisateurs;
  
  
  //********************************************************************************fonctions  administratives***********************************************************************************///

      //**************ajout utilisateur**********************//
      
      function ajouterUtilisateur (address adr, string[] memory _app) public returns (string memory){
          
        // c'est l'owner qui a le droit a l'ajout des utilisateur
    
       if( msg.sender == owner){
       
       //address ne doit pas exister
       
       if ( !exist(adr)){       
         
         
          //  ajout de l'utilisateur a la liste
          
            utilisateurs.push(adr);
            
          //creation d'un mapping qui va contenir les applications permises
          
             droits[adr] = _app;

             emit retour(now, "utilisateur ajouté avec succès..");

             } 
            else emit retour(now, "utilisateur existant...pensez a le modofier ");
             }


            else emit retour(now, "cette fonction est exclusive a l'administrateur");
          
       }

      //**************supprimer utilisateur**********************//

       function supprimerUtilisateur (address adr) public  {
          
        // c'est l'owner qui a le droit a l'ajout des utilisateur

         if( msg.sender == owner){
       
       //address ne doit pas exister
       
       if ( exist(adr)){ 
              
          //  la suppressionde l'utilisateur a la liste
          
             uint b;
             
            for (uint i = 0; i < utilisateurs.length; i++) 
            
                 {
                   if ( utilisateurs[i] == adr)
                   b = i;
                 } 
                 
            delete utilisateurs[b];

            delete droits[adr] ;

            emit retour(now, "utilisateur supprimé avec succès..");

            }

            else emit retour(now," cette utilisateur est inexistant....." );
         }

         else emit retour(now," cette fonction est exclusive a l'administrateur..." );        
       
       }

       //**************modifier utilisateur**********************//
        
       function modifierUtilisateur (address adr, string[] memory _app) public returns (string memory){
          
        // c'est l'owner qui a le droit a l'ajout des utilisateur
    
       if( msg.sender == owner){
       
       //address ne doit pas exister
       
       if ( exist(adr)){       
         
                     
          //creation d'un mapping qui va contenir les applications permises
          delete droits[adr];
             droits[adr] = _app;

             emit retour(now, "utilisateur modifié avec succès..");

             } 
            else emit retour(now, "utilisateur inexistant...pensez a l'ajouter ");
             }


            else emit retour(now, "cette fonction est exclusive a l'administrateur");
          
       }
       

      //**************voir toutes les address**********************//
      


        function voirUtilisateurs () public view returns (address[] memory)  {
            
            address[] memory reponses;//[1]  

          reponses[0] =  msg.sender;

         if( msg.sender == owner){

            return utilisateurs;

         }
         
         else return  reponses;
     
          

         } 
         
         
         
      //**************voir utilisateur**********************//
         
         function voirUtilisateur (address _address) public view returns (string[] memory)  {

          string[] memory reponses;//[1]  
          reponses[0] =  "cette utilisateur est inexistant....."; 

          if (exist(_address)){
          
              return droits[_address];}

         else 
              
              return   reponses;
        
        }

  //********************************************************************************fonctions  authentification***********************************************************************************///
  
  
         function authentication(address adr,string memory _app, bytes32 hash, bytes memory signature) public  view returns(string memory){
             
             
             //address  doit  exister
       
       if (exist(adr)) {
       
       if (recover(hash,signature) == adr){
       
             uint b= 0;
            
             for (uint i = 0; i < droits[adr].length; i++) {
                 
                 if ( compareStrings(droits[adr][i], _app) ) b = 1;
                 
             }
             
             if (b==1) return "ok";

             else return "non attribué";
             
       } else return "signature non valable";
                   
      }
      else return "cette utilisateur est inexistant.....";
         
         }


  //********************************************************************************fonctions  auxiliaires***********************************************************************************///



         //**************verifier existance utilisateur**********************//
         
        function exist (address _address)    private view returns (bool){
            
         bool b = false;
         
         for (uint i = 0; i < utilisateurs.length; i++) {
             
            if ( utilisateurs[i] == _address)
            
             b = true;
          }
          
             return b;

        }  


     function compareStrings(string memory a, string memory b) private  pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
           }
           
           
           
     
        function recover(bytes32 hash, bytes memory signature) private  pure returns (address){
            
          bytes32 r;
          bytes32 s;
          uint8 v;

          // Check the signature length
          if (signature.length != 65) {
             return (address(0));
            }

         // Divide the signature in r, s and v variables
         // ecrecover takes the signature parameters, and the only way to get them
         // currently is to use assembly.
         // solium-disable-next-line security/no-inline-assembly
         assembly {
         r := mload(add(signature, 0x20))
         s := mload(add(signature, 0x40))
         v := byte(0, mload(add(signature, 0x60)))
         }

          // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
         if (v < 27) {
          v += 27;
          }

         // If the version is correct return the signer address
         if (v != 27 && v != 28) {
          return (address(0));
           } else {
         // solium-disable-next-line arg-overflow
        return ecrecover(hash, v, r, s);
    }
  }

}
