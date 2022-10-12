#To activate anywhere run command: alias script_identifier="/path/to/file.sh"
#!/bin/bash


echo -e "Show Rules for which Chain?\n
1. INPUT
2. OUTPUT
3. FORWARD
4. DOCKER-USER"

read -s chain
case $chain in
  1) iptables -L INPUT -v -n --line-numbers && chain=INPUT ;;
  2) iptables -L OUTPUT -v -n --line-numbers && chain=OUTPUT ;;
  3) iptables -L FORWARD -v -n --line-numbers && chain=FORWARD ;;
  4) iptables -L DOCKER-USER -v -n --line-numbers && chain=DOCKER-USER ;;
  *) echo -e "Wrong Options"
esac

echo -e "Add/Replace/Delete Rule?\n"

read -s ans

#Add rule logic -----------------------------------------------------------------------

if [ "$ans" == 'add' ] || [ "$ans" == 'a' ] || [ "$ans" == 'Add' ]
then

  echo " Rule Number to add?"
  read -s nr
  echo "Give interface name"
  read interface
  echo "Give PORTS(seperate with ',')"
  read ports
  echo "Specify IP(s)."
  read ip
  echo "Specify action(DROP/ACCEPT)"
  read -s action
  if [ $action == 'DROP' ] || [ $action == 'drop' ] || [ $action == 'Drop' ] || [ $action == 'd' ] || [ $action == 'D' ]
  then
    action='-j DROP'
  else
    action='-j ACCEPT'
  fi
    

  if [[ $ip = "" ]]
  then
    echo "No IP given. Adding rule without source IP."
    iptables -I $chain $nr -i $interface -p tcp -m multiport --dport $ports $action
  else
    for i in $ip
    do
      echo "Adding rule for $i"
      iptables -I $chain $nr -i $interface -s $i -p tcp -m multiport --dport $ports $action
    done
  fi

  iptables -L $chain -v -n --line-numbers



fi

#Replace rule logic ----------------------------------------------------------
if [ $ans == 'replace' ] || [ $ans == 'r' ] || [ $ans == 'Replace' ]
then

  echo 'Which rule to replace'
  read -s nr
  echo 'Choose interface'
  read interface
  echo 'Give ports, seperated with "," '
  read ports
  echo 'Drop or Accept?'
  read -s access
  if [ $access == 'drop' ] || [ $access == 'd' ] || [ $access == 'Drop' ]
  then
    access='-j DROP' 
    rule= iptables -R $chain $nr -i $interface -p tcp -m multiport --dport $ports $access 
  else
    access='-j ACCEPT' 
    rule= iptables -R $chain $nr -i $interface -p tcp -m multiport --dport $ports $access 
  fi
    
  $rule 
 
fi


#Delete rule logic ----------------------------------------------------------

if [ $ans == 'delete' ] || [ $ans == 'd' ] || [ $ans == 'Delete' ]
then
  echo 'Which rule to delete.'
  counter=1
  read nr
 
  while [ "$counter" == 1 ]
  do
    iptables -D $chain $nr
    iptables -L $chain -v -n --line-numbers
    echo 'Delete another rule? (1/0)'
    read counter
  done
fi

#Save or Not rules logic------------------------------------------------------------------------
echo "Rules for $chain are updated.Save and exit?"
read -s save

    if [  "$save" == 'yes' ] || [ "$save" == 'y' ] || [ "$save" == '1' ] || [ "$save" == 'Yes' ] || [ "$save" == 'Y' ]
    then

      netfilter-persistent save #save rules
    else
      echo "Rules not saved" #Not saving
    fi
    



#Show rules after changes
iptables -L $chain -v -n --line-numbers
