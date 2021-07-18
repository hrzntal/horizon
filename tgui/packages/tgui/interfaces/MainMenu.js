/**
 * @file
 * @copyright 2021 Avunia Takiya (https://takiya.eu)
 * @license MIT
 */

import { useBackend } from '../backend';
import { BlockQuote, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export const MainMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { title, mapdesc, player_ready, game_state, buttons } = data;

  const lore_info = (
    <Section scrollable>
      <BlockQuote top="32">
        {mapdesc}
      </BlockQuote>
    </Section>
  );

  const pregame_buttons = (
    <Stack horizontal>
      <Stack.Item>
        <Button
          content="Ready"
          onClick={() => act("ready")}
          selected={player_ready === 1}
          lineHeight={2}
        />
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Button
          content="Not Ready"
          onClick={() => act("unready")}
          selected={player_ready === 0}
          lineHeight={2}
        />
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Button
          content="Observe"
          onClick={() => act("observe")}
          lineHeight={2}
        />
      </Stack.Item>
    </Stack>
  );

  const latejoin_buttons = (
    <Stack vertical>
      <Stack.Item>
        <Button
          content="Join Game!"
          icon={'sign-in-alt'}
          onClick={() => act("latejoin")}
          lineHeight={2}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="Observe"
          icon={'ghost'}
          onClick={() => act("observe")}
          lineHeight={2}
        />
      </Stack.Item>
    </Stack>
  );

  const menu_buttons = (
    <Section grow>
      <Stack fill vertical align="center" justify="flex-start">
        <Stack.Item>
          <Button
            content="Character Setup & Settings"
            icon={'tools'}
            onClick={() => act("setup")}
            lineHeight={2}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            content="View The Crew Manifest"
            icon={'list'}
            onClick={() => act("crew_manifest")}
            lineHeight={2}
          />
        </Stack.Item>
        { (game_state <= 1) ? (
          <Stack.Item>
            { pregame_buttons }
          </Stack.Item>
        ) : (
          <Stack.Item>
            { latejoin_buttons }
          </Stack.Item>
        ) }
      </Stack>
    </Section>
  );

  return (
    <Window
      title={title}
      width={400}
      height={330}
      canClose={false}
    >
      <Window.Content>
        { lore_info }
        { menu_buttons }
      </Window.Content>
    </Window>
  );
};
