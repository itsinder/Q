#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <curl/curl.h>


int request_server(char * input)
{
  int status = 0;
  CURL *ch = NULL;
  CURLcode curl_res;
 
  curl_global_init(CURL_GLOBAL_ALL);
  ch = curl_easy_init();
  if(ch) {
    curl_easy_setopt(ch, CURLOPT_URL, "http://localhost:8000/Dummy?ABC=123");
    curl_easy_setopt(ch, CURLOPT_POSTFIELDS, input);
    curl_res = curl_easy_perform(ch);
    if(curl_res != CURLE_OK) {
      status = -1;
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(curl_res));
    }
    curl_easy_cleanup(ch);
  }
  else {
    status = -1;
  }
  curl_global_cleanup();
BYE:
  return status;
}


int main()
{
  char *input;
  int status = 0;

  while ( 1 )
  {
    input = readline("Enter text: ");
    add_history(input);
    // printf("%s", input);
    if ( strcmp(input, "os.exit()") == 0 ) {
      break;
    }
    status = request_server(input);
    printf("\n");
  }
  return 0;
}
