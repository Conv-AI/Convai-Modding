#include "audio.h"
#include "interaction.h"
#include "proto_utils.h"
#include <cmath>
#include <string>
#include <fstream>
#include <iostream>
#include <Windows.h>

using convai_sdk::Audio;
using convai_sdk::FRAMES_PER_BUFFER;
using convai_sdk::Interaction;
using convai_sdk::RECORD_SECONDS;
using convai_sdk::SAMPLING_RATE;
using convai_sdk::proto_util::GetResponseConfigFromFile;
using service::GetResponseRequest;
using service::GetResponseResponse;

static constexpr int WAV_HEADER_SIZE = 44;
static constexpr char GET_RESPONSE_CONFIG_FILE[] = "get_response_config_example.txt";
static constexpr char SESSION_FILE[] = "session.txt";

std::string ReadSessionIdFromFile() {
  std::ifstream sessionFile(SESSION_FILE);
  std::string sessionId;
  if (sessionFile.is_open()) {
    std::getline(sessionFile, sessionId);
    sessionFile.close();
  }
  return sessionId;
}

void WriteSessionIdToFile(const std::string& sessionId) {
  std::ofstream sessionFile(SESSION_FILE);
  if (sessionFile.is_open()) {
    sessionFile << sessionId;
    sessionFile.close();
  }
}

int main() {
  // Hide the console window

  //FreeConsole();

  GetResponseRequest::GetResponseConfig get_response_config =
      GetResponseConfigFromFile(GET_RESPONSE_CONFIG_FILE);

  // Check session.txt for session ID
  std::string sessionIdFromFile = ReadSessionIdFromFile();
  if (!sessionIdFromFile.empty()) {
    get_response_config.set_session_id(sessionIdFromFile);
  }

  Audio audio_in;
  Audio audio_out;
  Interaction interaction(get_response_config);

  std::string transcript = "";
  std::string temp_transcript = "";
  std::string action_response_text = "";

  // Open a text file for writing
  std::ofstream outputFile("response.txt");
  std::ofstream lipsyncFile("lipsync.txt");

  interaction.Start(
      [&audio_out, &get_response_config, &transcript, &temp_transcript, &outputFile, &action_response_text, &lipsyncFile](GetResponseResponse resp) {
        if (resp.has_user_query()) {
          auto user_query = resp.user_query();
          if (user_query.is_final()) {
            transcript += user_query.text_data();
            temp_transcript = "";
          } else {
            temp_transcript = user_query.text_data();
          }
          std::cout << "You: " << transcript << temp_transcript;
          if (!user_query.end_of_response()) {
            std::cout << '\r';
            std::cout.flush();
          } else {
            std::cout << std::endl;
            std::cout << "Bot: ";
          }

          // Write the response to the text file
          outputFile << "You: " << transcript << temp_transcript;
          if (!user_query.end_of_response()) {
            outputFile << '\r';
          } else {
            outputFile << std::endl;
            outputFile << "Bot: ";
          }
        } else if (resp.has_action_response()) {
          action_response_text = resp.action_response().action();
        } else if (resp.has_audio_response()) {
          if (get_response_config.session_id() == "") {
            get_response_config.set_session_id(resp.session_id());
            // Save the session ID to session.txt
            WriteSessionIdToFile(resp.session_id());
          }
          std::cout << resp.audio_response().text_data() << std::endl;
          if (resp.audio_response().end_of_response()) {
            std::cout << std::endl;
          }

          if (resp.audio_response().audio_data() != "") {
            if (!audio_out.Started()) {
              lipsyncFile << "start";
              lipsyncFile.close();
              audio_out.Start(
                  resp.audio_response().audio_config().sample_rate_hertz());
            }
            const std::string audio_d =
                resp.audio_response().audio_data().substr(WAV_HEADER_SIZE);
            const int16_t *audio_int = (const int16_t *)audio_d.data();
            int64_t num_frames =
                (audio_d.length() * sizeof(char)) / sizeof(int16_t);
            audio_out.WriteBuffer(audio_int, num_frames);
          }

          // Write the response to the text file
          outputFile << resp.audio_response().text_data() << std::endl;
          if (resp.audio_response().end_of_response()) {
            outputFile << std::endl;
          }
        }
      });

  std::cout << "Started Recording: " << std::endl;
  audio_in.Start();
  for (int i = 0; i < (SAMPLING_RATE / FRAMES_PER_BUFFER * RECORD_SECONDS);
       ++i) {
    int16_t buffer[FRAMES_PER_BUFFER];
    audio_in.ReadBuffer(buffer);
    char *audio_data = (char *)buffer;
    int length = FRAMES_PER_BUFFER * sizeof(int16_t) / sizeof(char);
    interaction.SendAudio(audio_data, length);
  }
  audio_in.Close();
  auto status = interaction.Stop();
  if (audio_out.Started()) {
    audio_out.Close();
  }
  if (!action_response_text.empty()) {
    outputFile << "Action: " << action_response_text;
  }
  outputFile.close(); // Close the text file
  if (!status.ok()) {
    exit(1);
  }

  return 0;
}
